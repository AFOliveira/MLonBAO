# IA&AI

## Interference Analysis in Multi-Core Embedded AI Systems

## Authors

- Afonso Oliveira
- Gonçalo Moreira
- Diogo Costa
- Prof. Tiago Gomes
- Prof. Sandro Pinto

## Overview

This repository contains the analysis and findings of the paper  "IA&AI: Interference Analysis in Multi-core Embedded AI Systems." 

## Abstract
Significant advances in Artificial Intelligence (AI) over the past decade have opened new aisles of exploration for industries such as automotive and industrial robotics, leading to the widespread adoption of AI. To meet the demands of modern applications, embedded platforms have evolved into highly heterogeneous designs, transitioning from simple microcontroller-based systems to intricate platforms with multiple processor units and hardware accelerators. Driven by Size, Weight, Power, and Cost (SWAP-C) constraints, both industry and academia have focused on consolidating systems with different criticality levels, referred to as mixed-criticality systems (MCS), onto a single hardware platform. However, the co-existence of heterogeneous designs can still raise several safety and security issues, which can be addressed through secure computer architectures and hypervisor technologies that provide spatial and temporal isolation features. This paper discusses the impact of MCS consolidation on AI-based applications. The setup uses the Bao hypervisor to deploy two virtual machines (VMs): one VM hosting TensorFlow Lite to run AI workloads on a Linux system, and the other supporting a bare-metal memory-intensive application. The study involves running Convolutional Neural Networks (CNNs) and Deep Neural Networks (DNNs) machine learning models (ML), based on two widely used classification datasets: MNIST and CIFAR-10, while assessing the impact of sharing platform resources with a memory-intensive application. Empirical results show that contention on last-level cache and system bus can significantly impact the inference process of an ML model up to 6.39x.


## Contents

- `DeviceTrees/rpi4/`: Device tree files for Raspberry Pi 4.
- `Meeting Notes/`: Notes from project meetings.
- `PreBuiltImages/`: Prebuilt firmware images.
- `TrainedModels/`: Pre-trained ML models used in the experiments.
- `bao-configs/`: Configuration files for the Bao hypervisor.
- `bao-hypervisor/`: Submodule including the Bao hypervisor.
- `docker/`: Docker configuration files.
- `docs/`: Documentation for the project.
- `guests/`: Guest VM configurations and setups.
- `results/`: Results of the experiments.
- `scripts/`: Scripts for setting up and running the experiments.
- `wrkdir/imgs/`: Working directory images.
