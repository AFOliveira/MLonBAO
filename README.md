# MLonBAO

## Impact Analysis of Contention on Multi-Core Platforms for Real-Time Critical Applications and Machine Learning

## Authors

- Afonso Oliveira (PG53599)
- Gonçalo Moreira (PG53841)

## Supervision

- Diogo Costa
- Sandro Pinto

## Overview

This repository contains the analysis and findings of the project "Impact Analysis of Contention on Multi-Core Platforms for Real-Time Critical Applications and Machine Learning." The project investigates the effects of hardware contention on the performance of machine learning (ML) applications running on multicore platforms. The study focuses on mixed-criticality systems (MCS) and explores techniques to mitigate the impact of contention using the Bao hypervisor.

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
- `.gitmodules`: Git submodules configuration file.

### Prerequisites

- Python 3.10 or higher
- TensorFlow
- Bao hypervisor

