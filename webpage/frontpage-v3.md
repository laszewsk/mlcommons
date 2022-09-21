---
eleventyNavigation:
  key: "Research Science Working Group"
  title: "Science"
  parent: "Research Working Group"
  order: 6
title: Science Working Group
layout: group.njk
---

# Mission

Encourage and support the curation of large-scale experimental and
scientific datasets and the engineering of ML benchmarks operating on
those datasets. The WG will engage with scientists, academics,
national laboratories, such as synchrotrons, in securing, engineering,
curating, and publishing datasets and machine learning benchmarks that
operate on experimental scientific datasets. This will entail working
across different domains of sciences, including material, life,
environmental, and earth sciences, particle physics, and astronomy, to
mention a few. We will include traditional observational and
computer-generated data.

Although scientific data is widespread, curating, maintaining, and
distributing large-scale, useful datasets for public consumption is a
challenging process, covering various aspects of data (from FAIR
principles to distribution to versioning). With large data products,
various ML techniques have to be evaluated against different
architectures and different datasets. Without these benchmarking
efforts, the community has no clear pathway for utilizing these
advanced models. We expect that the collection will have significant
tutorial value as examples from one field, and one observational or
computational experiment can be modified to advance other fields and
experiments.

The working group’s goal is to assemble and distribute scientific data
sets relevant to a scientific campaign in a systematic manner, and
pose quantifiable targets (“science benchmark"). A benchmark involves
(i) a data set, (ii) objective criteria to meet, and (iii) an example
implementation. The objective criteria depends on the scientific
problem at hand. The metric should be well defined on the data but
could come from a diverse set of measures (one or more of: accuracy
targets, top-1 or 5% error, time to convergence, cross-validation
rates, confusion matrices, type-1/type-2 error rates, inference times,
surrogate accuracy, control stability measure, etc.).  

## Deliverables

* Develop a nuber of Science Benchmarks

Current benchmarks include


| Benchmark 	| Science 	 | Task              | 	Owner Institute | 	GitHub                                                               |
| --- |-----------|-------------------| --- |-----------------------------------------------------------------------|
| CloudMask 	| Climate 	 | Segmentation      | 	RAL 	| [cloudmask](https://github.com/mlcommons/science/blob/main/benchmarks/cloudmask/README.md) |
| STEMDL | 	Material | 	Classification 	 | ORNL 	    | [stemdl](https://github.com/mlcommons/science/tree/main/benchmarks/stemdl)                                            |
| CANDLE-UNO | 	Medicine | 	Classification   |	ANL | 	[candle-uno](https://github.com/mlcommons/science/tree/main/benchmarks/uno)                                          |
| TEvolOp Forecasting |	Earthquake | 	Regression 	     | University of Virginia | 	[tevolop](https://github.com/mlcommons/science/tree/main/benchmarks/earthquake)                                      |


## Meeting Schedule

* Bi-weekly on Wednesay from 8:00-9:00AM Pacific.
* Mailing List: science@googlegroups.com

* Working Group Chairs

  * Geoffrey Fox (gcfexchange@gmail.com) 
  * Tony Hey (tony.hey@stfc.ac.uk) 
  * Jeyan Thiyagalingam (t.jeyan@stfc.ac.uk)




## Resources


The main working group Web page is at: 

* <https://mlcommons.org/en/groups/research-science/>

The working group github is located at 

* <https://github.com/mlcommons/science>

The Policy document is located at 

* <https://github.com/mlcommons/science/blob/main/policy.adoc>

The following descriptions and code to scientific benchmarks are avialable at:

* [Cloudmask](https://github.com/mlcommons/science/blob/main/benchmarks/cloudmask/README.md)
* [Earthqauke](https://github.com/mlcommons/science/blob/main/benchmarks/earthquake/README.md)
* [Stemdl](https://github.com/mlcommons/science/tree/main/benchmarks/stemdl)
* [Uno](https://github.com/mlcommons/science/tree/main/benchmarks/uno)

## Deveopment versions 

Development versions of the codes prior to upload to the mlcommons directory are avalable as follows:

* [Science Policy Document](https://github.com/laszewsk/mlcommons/blob/main/www/content/en/docs/policy.adoc)
* [Benchmarks](https://github.com/laszewsk/mlcommons/tree/main/benchmarks)
