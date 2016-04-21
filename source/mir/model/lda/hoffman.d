/++
References:
	Hoffman, Matthew D., Blei, David M. and Bach, Francis R..
	"Online Learning for Latent Dirichlet Allocation.."
	Paper presented at the meeting of the NIPS, 2010.
+/
module mir.model.lda.hoffman;

import mir.ndslice.slice;
import mir.sparse;

//private computeExpectationTheta(Slice!(2, R) gamma, )
//{

//}

//private void normalizeRows(T)(Slice!(2, T*) matrix, Slice!(1, R) b, in E def)
//{
//	assert(a.shape == b.shape);

//	import mir.math: expDigamma;
//	import mir.sum: sum;

//	auto d = digamma(def);
//	foreach(x; a)
//	{
//		auto ds = expDigamma(sum(x));
//		auto y = b.front;
//		foreach(e; x)
//		{
//			y.front = (def == e ? d : digamma(e)) - ds;
//			y.popFront;
//		}
//		b.popFront;
//	}
//}

void mm ()
{
	alias R = double;
	alias C = uint;
	C s, d;
	R alpha;
	R eta;
	CompressedTensor!(2, C) n; // [t, w]

	Slice!(2, R*) gamma;  // [t, k]
	Slice!(2, R*) theta;  // [t, k]

	Slice!(2, R*) lambda; // [k, w]
	Slice!(2, R*) beta;   // [k, w]

	import mir.math: expDigamma, expMEuler;
	import mir.sum: sum;
	import mir.blas.gemm;
	import mir.sparse.blas.gemm;
	import mir.ndslice.iteration: transposed;


	auto gt = assumeSameStructure!("gamma", "theta")(gamma, theta);
	auto lb = assumeSameStructure!("lambda", "beta")(lambda, beta);
	gamma[] = 1; // not nan!
	//theta[] = expMEuler;
	
	// update beta
	/// Нормировка
	do
	{
		// update theta
		gemm!R(1, n, beta.transposed, 0, gamma);
		foreach(r; gt)
		{
			foreach(e; r)
			{
				e.theta = expDigamma(e.gamma = e.gamma * e.theta + alpha);
			}
		}
	}
	while(false);
	gemtm!R(1, n, theta, 0, lambda);
	auto c = R(d) / R(s);
	foreach(r; lb)
	{
		foreach(e; r)
		{
			e.beta = expDigamma(e.lambda = e.lambda * e.beta * c + eta);
		}
	}
	lambda[] *= beta;
	lambda[] *= R(d) / R(s);
	lambda[] += eta;
}





