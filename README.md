
### Docker tensorflow-py3

Docker that contains:

+ Tensorflow
+ [TensorFlow Probability](https://github.com/tensorflow/probability) (only in the GPU version)
+ [Sonnet](https://github.com/deepmind/sonnet) (only in the GPU version)
+ OpenCV (latest - build from source)
+ FFMPEG (build from source)
+ [gdrive](https://github.com/prasmussen/gdrive)
+ NLTK


#### Overview

This repository contains dockerfiles versions for both CPU and GPU. You can build both versions with:
`make build-cpu` and `make build-gpu`.
   
In order to define the version of Tensorflow you can change the variable `TAG_VERSION_TF` or `TAG_VERSION_TF_CPU` in the file `Makefile`. 

Example: `TAG_VERSION_TF_GPU=1.11.0-gpu-py3` will build Tensorflow from the [tag](https://hub.docker.com/r/tensorflow/tensorflow/tags) tensorflow/tensorflow:1.11.0-gpu-py3


##### References

+ This repository is based on [docker-tensorflow-opencv3](https://github.com/so77id/docker-tensorflow-opencv3)