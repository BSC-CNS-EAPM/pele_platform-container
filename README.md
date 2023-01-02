# pele_platform-container


PELE Platform is a suite of packages that aims to find novel solutions to drug discovery problems in a matter of hours. Most of its tools revolve around PELE, our proprietary software to explore the potential energy surface of biochemical systems.

The github of the pele_platform can be found: [Github](https://github.com/nostrumbiodiscovery/pele_platform)

How to use the pele_platform container
---
This container can only be used in one node. Multi-node execution is not possible.

Workflow to execute a simulation:
1. Copy or modify the files in sharedDirectory.
  - input.yaml: the config file (see [pele_platform documentation](https://nostrumbiodiscovery.github.io/pele_platform/input/yaml.html) for more info).
    - Must have the system path -> complex.pdb.
    - If there is a template must have the templates path -> ndpz (name may be different).
  - complex.pdb: the pdb of the complex to study.
  - ndpz: a templete file (name may be different).
  - License: where the PELE licenses are stored.
2. Launch the platform.sif with the following command:
```
singularity run -B /home/oxipro/platform/sharedDirectory:/home/pele_platform platform.sif
```
3. When the simulation is finished a folder with the results should appear in your sharedDirectory.
4. For more information how to run pele_platform see the [documentation](https://nostrumbiodiscovery.github.io/pele_platform/).
