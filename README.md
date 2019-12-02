# Forest Defender

Forest Defender is a system built for the Microsoft Azure Sphere that performs continuous audio recording and classification in order to detect wildfires or illegal logging and notify law enforcement in real-time. It connects with Azure Cloud Services to send notifications. Read [this blog post](https://www.element14.com/community/groups/azuresphere/blog/2019/12/01/forest-defender-protecting-our-forests-with-machine-learning) for more info on how the project developed.

## Setup and Running

This repository consists of two main parts, the embedded software for the Azure Sphere, and the mobile app for interacting with the system.

Instructions for installing and running each part can be found in the README in each directory.

### Audio Classifier Training Notebook

The Forest_Defender_Audio_Classifier.ipynb is a Python notebook built to run on Google Colab and used to train the machine learning model that runs on the Azure Sphere. Colab has everything needed to run the notebook already installed. Just open the notebook in a browser and explore it.

<a href="https://colab.research.google.com/github/jdpwebb/forest-defender/blob/master/Forest_Defender_Audio_Classifier.ipynb" rel="nofollow noopener" target="_blank"><img alt="Open In Colab" class="lazyload" loading="lazy" data-src="https://colab.research.google.com/assets/colab-badge.svg" src="https://colab.research.google.com/assets/colab-badge.svg">
</a>
