/++
$(H3 Online variational Bayes for latent Dirichlet allocation)


References:
	Hoffman, Matthew D., Blei, David M. and Bach, Francis R..
	"Online Learning for Latent Dirichlet Allocation.."
	Paper presented at the meeting of the NIPS, 2010.
+/
module mir.model.lda.hoffman;

import std.traits;

/++
Batch variational Bayes for LDA with mini-batches.
+/
struct LdaHoffman(F)
	if (isFloatingPoint!F)
{
	import std.parallelism;
	import std.range: iota;

	import mir.ndslice.slice;

	import mir.internal.math;
	import mir.sparse;

	private alias Vector = Slice!(1, F*);
	private alias Matrix = Slice!(2, F*);

	private size_t D;
	private F alpha;
	private F eta;
	private F kappa;
	private F _tau;
	private F eps;

	private Matrix _lambda; // [k, w]
	private Matrix _beta;   // [k, w]

	private TaskPool tp;

	private F[][] _lambdaTemp;

	@disable this();
	@disable this(this);

	/++
	Params:
		K = theme count
		W = dictionary size
		D = approximate total number of documents in a collection.
		alpha = Dirichlet document-topic prior (0.1)
		eta = Dirichlet word-topic prior (0.1)
		tau0 = 𝞽0 ≧ 0 slows down the early iterations of the algorithm.
		kappa = `𝞳 ∈ (0.5, 1]`, controls the rate at which old values of 𝝺 are forgotten. 
			`𝝺 = (1 - 𝞀(𝞽)) 𝝺 + 𝞀 𝝺',  𝞀(𝞽) = (𝞽0 + 𝞽)^(-𝞳)`. Use `𝞳 = 0` for Batch variational Bayes LDA.
		eps = Stop iterations if `||𝝺 - 𝝺'||_l1 < s * eps`, where `s` is a documents count in a batch.
		tp = task pool
	+/
	this(size_t K, size_t W, size_t D, F alpha, F eta, F tau0, F kappa, F eps = 1e-5, TaskPool tp = taskPool())
	{
		import std.random: uniform;

		this.D = D;
		this.alpha = alpha;
		this.eta = eta;
		this._tau = tau0;
		this.kappa = kappa;
		this.eps = eps;
		this.tp = tp;

		_lambda = slice!F(K, W);
		_beta = slice!F(K, W);
		_lambdaTemp = new F[][](tp.size + 1, W);

		foreach(r; tp.parallel(_lambda))
			foreach(ref e; r)
				e = uniform(F(0.9), F(1));

		updateBeta();
	}

	///
	void updateBeta()
	{
		foreach (i; tp.parallel(lambda.length.iota))
			unparameterize(lambda[i], beta[i]);
	}

	/++
	Posterior over the topics
	+/
	Slice!(2, F*) beta() @property
	{
		return _beta;
	}

	/++
	Parameterized posterior over the topics.
	+/
	Slice!(2, F*) lambda() @property
	{
		return _lambda;
	}

	/++
	Count of already seen documents.
	Slows down the iterations of the algorithm.
	+/
	F tau() const @property
	{
		return _tau;
	}
	
	/// ditto
	void tau(F v) @property
	{
		_tau = v;
	}

	/++	
	Accepts mini-batch and performs multiple E-step iterations for each document and single M-step.

	This implementation is optimized for sparse documents,
	which contain much less unique words than a dictionary.

	Params:
		n = mini-batch, a collection of compressed documents.
		maxIterations = maximal number of iterations for single document in a batch for E-step.
	+/
	size_t putBatch(S : Slice!(1, R), R : CompressedMap!(C, I, J), C, I, J)(S n, size_t maxIterations)
	{
		return putBatchImpl(n.recompress!F, maxIterations);
	}

	private size_t putBatchImpl(CompressedTensor!(2, F) n, size_t maxIterations)
	{
		import std.math: isFinite;
	 	import mir.sparse.blas.dot;
	 	import mir.sparse.blas.gemv;
		import mir.ndslice.iteration: transposed;
		import mir.internal.utility;

		immutable S = n.length;
		immutable K = _lambda.length!0;
		immutable W = _lambda.length!1;
		_tau += S;
		auto theta = slice!F(S, K);
		auto nsave = saveN(n);
		
		immutable rho = pow!F(F(tau), -kappa);
		auto thetat = theta.transposed;
		auto _gamma = slice!F(tp.size + 1, K);
		shared size_t ret;
		// E step
		foreach(d; tp.parallel(S.iota))
		{
			auto gamma = _gamma[tp.workerIndex];
			gamma.toDense[] = 1;
			auto nd = n[d];
			auto thetad = theta[d];
			for(size_t c; ;c++)
			{
				unparameterize(gamma, thetad);

				selectiveGemv!"/"(_beta.transposed, thetad, nd);
				F sum = 0;
				{
					auto beta = _beta;
					auto th = thetad;
					foreach(ref g; gamma)
					{
						if(!th.front.isFinite)
							th.front = F.max;
						auto value = dot(nd, beta.front) * th.front + alpha;
						sum += fabs(value - g);
						g = value;
						beta.popFront;
						th.popFront;
					}
				}
				if(c < maxIterations && sum > eps * K)
				{
					nd.values[] = nsave[d].values;
					continue;
				}
				import core.atomic;
				ret.atomicOp!"+="(c);
				break;
			}
		}
		// M step
		foreach(k; tp.parallel(K.iota))
		{
			auto lambdaTemp = _lambdaTemp[tp.workerIndex];
			gemtv!F(F(1), n, thetat[k], F(0), lambdaTemp);
			auto l = _lambda[k].toDense;
			l[] = (1 - rho) * l[] + 
				rho * (eta + (F(D) / F(S)) * _beta[k].toDense[] * lambdaTemp[]);
			unparameterize(_lambda[k], _beta[k]);
		}
		return ret;
	}

	private auto saveN(CompressedTensor!(2, F) n)
	{
		return
			CompressedMap!(F)(
				n.ptr.range.compressedLength,
				n.ptr.range.values.dup,
				n.ptr.range.indexes,
				n.ptr.range.pointers)
			.sliced(n.length);
	}

	private static void unparameterize(Vector param, Vector posterior)
	{
		assert(param.structure == posterior.structure);
		import mir.math: expDigamma;
		import mir.sum: sum;
		immutable c = 1 / expDigamma(sum(param));
		foreach(e; assumeSameStructure!("param", "posterior")(param, posterior))
			e.posterior = c * expDigamma(e.param);
	}
}

unittest
{
	alias ff = LdaHoffman!double;
}
