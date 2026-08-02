

# IA&AI

## Análisis de Interferencia en Sistemas Embebidos de IA de Múltiples Núcleos

## Autores

- Afonso Oliveira
- Gonçalo Moreira
- Diogo Costa
- Prof. Tiago Gomes
- Prof. Sandro Pinto

## Visión General

Este repositorio contiene el análisis y los hallazgos del artículo "IA&AI: Interference Analysis in Multi-core Embedded AI Systems." 

## Resumen
Los avances significativos en Inteligencia Artificial (IA) durante la última década han abierto nuevas vías de exploración para industrias como la automotriz y la robótica industrial, lo que ha llevado a la amplia adopción de la IA. Para satisfacer las demandas de las aplicaciones modernas, las plataformas embebidas han evolucionado hacia diseños altamente heterogéneos, transitando desde sistemas simples basados en microcontroladores hasta plataformas complejas con múltiples unidades de procesamiento y aceleradores de hardware. Impulsadas por las restricciones de Tamaño, Peso, Consumo y Costo (SWAP-C), tanto la industria como la academia se han centrado en consolidar sistemas con diferentes niveles de criticidad, denominados sistemas de criticidad mixta (MCS), en una única plataforma de hardware. Sin embargo, la coexistencia de diseños heterogéneos aún puede plantear varios problemas de fiabilidad y seguridad, los cuales pueden abordarse mediante arquitecturas de computación seguras y tecnologías de hipervisores que ofrecen características de aislamiento espacial y temporal. Este artículo analiza el impacto de la consolidación de MCS en aplicaciones basadas en IA. La configuración utiliza el hipervisor Bao para desplegar dos máquinas virtuales (VMs): una VM que aloja TensorFlow Lite para ejecutar cargas de trabajo de IA en un sistema Linux, y la otra que soporta una aplicación intensiva en memoria en bare-metal. El estudio implica la ejecución de modelos de aprendizaje automático (ML) de Redes Neuronales Convolucionales (CNNs) y Redes Neuronales Profundas (DNNs), basados en dos conjuntos de datos de clasificación ampliamente utilizados: MNIST y CIFAR-10, mientras se evalúa el impacto de compartir recursos de la plataforma con una aplicación intensiva en memoria. Los resultados empíricos muestran que la contención en la caché de último nivel y el bus del sistema puede afectar significativamente el proceso de inferencia de un modelo de ML hasta en un factor de 6.39x.


## Contenido

- `DeviceTrees/rpi4/`: Archivos device tree para Raspberry Pi 4.
- `Meeting Notes/`: Notas de las reuniones del proyecto.
- `PreBuiltImages/`: Imágenes de firmware precompiladas.
- `TrainedModels/`: Modelos de ML preentrenados utilizados en los experimentos.
- `bao-configs/`: Archivos de configuración para el hipervisor Bao.
- `bao-hypervisor/`: Submódulo que incluye el hipervisor Bao.
- `docker/`: Archivos de configuración de Docker.
- `docs/`: Documentación del proyecto.
- `guests/`: Configuraciones y entornos de las máquinas virtuales huésped.
- `results/`: Resultados de los experimentos.
- `scripts/`: Scripts para configurar y ejecutar los experimentos.
- `wrkdir/imgs/`: Imágenes del directorio de trabajo.
