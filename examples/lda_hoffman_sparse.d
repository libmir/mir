#!/usr/bin/env dub
/+ dub.sdl:
name "lda_hoffman_sparse"
dependency "mir" version=">0.15.1"
+/

/++
Butch LDA using online LDA
+/
import std.file;
import std.path;
import std.string;
import std.utf;
import std.conv;
import std.algorithm;
import std.range;
import std.stdio;

import mir.sparse;
import mir.model.lda.hoffman;


void main(string[] args)
{
    string curFolder;
    if (args.length > 1)
        curFolder = args[1];
    else
        curFolder = thisExePath.dirName;

	auto stop = curFolder.buildPath("data/stop_words")
		.readText
		.lineSplitter
		.map!(toLower)
		;

	bool[string] stopSet;
	foreach(word; stop)
		stopSet[word] = true;

	auto dict = curFolder.buildPath("data/words")
		.readText
		.lineSplitter
		.map!(toLower)
		.filter!(a => !a.empty && (a !in stopSet))
		.array
		.sort()
		.release
		.uniq
		.array
		;

	auto docs = curFolder.buildPath("data/trndocs.dat")
		.readText
		.splitLines
		;

	auto collection = sparse!uint(docs.length, dict.length);

	foreach(i, doc; docs)
	{
		foreach(word; doc.splitter.filter!(a => !a.empty))
		{
			auto t = dict.assumeSorted.trisect(word);
			if(t[1].length)
				collection[i, t[0].length] += 1;
		}
	}

	auto comp = collection.compress;
	auto k = 100;
	import std.parallelism;
	auto lda = LdaHoffman!double(
		k, // topics count
		dict.length, // dictionary length
		comp.length, // ~ value of documents
		0.1, // alpha
		0.1, // eta
		0,  // unused for butch version
		0.0, // null for butch version
		1e-5, // epsilon for E step
		);

	foreach(_; 0..20)
	{
		auto iters = lda.putBatch(comp, 1000);
		writeln(iters);
	}

	foreach(theme; lda.beta)
	{
		uint[16] index;
		topNIndex!"a > b"(theme, index[], SortOutput.yes);
		dict.indexed(index[]).writeln;
	}
}
