# Tarea 5.1: Estudio analítico de arquitecturas de virtualización e hipervisores

**Materia:** Administrador de Servidores  
**Entorno de trabajo:** Local (Windows 11)

---

## 1. Marco Analítico y Principios de Virtualización

La virtualización permite abstraer los recursos físicos de hardware mediante un hipervisor o VMM (Monitor de Máquina Virtual), permitiendo ejecutar múltiples sistemas operativos aislados de forma simultánea.

* **Hipervisores Tipo 1 (Bare-Metal):** Se instalan directamente sobre el hardware físico, ofreciendo el máximo rendimiento y eficiencia al no depender de un sistema operativo intermedio (Ej. Proxmox VE, VMware ESXi, Hyper-V Server).
* **Hipervisores Tipo 2 (Hosted):** Se ejecutan como aplicaciones sobre un Sistema Operativo anfitrión (Host OS). Son ideales para pruebas y laboratorios locales, aunque presentan mayor sobrecarga (Ej. Oracle VirtualBox, VMware Workstation).
* **Contenedores de Sistema Operativo:** Virtualizan a nivel de núcleo (Kernel), compartiendo el kernel del host. Son extremadamente ligeros y rápidos (Ej. Docker mediante WSL 2).

---

## 2. Tabla Comparativa Técnica

| Criterio de Evaluación | Hipervisores Tipo 1 (Bare-Metal) | Hipervisores Tipo 2 (Hosted) | Contenedores de SO |
| :--- | :--- | :--- | :--- |
| **Sobrecarga de Hardware (Overhead)** | **Muy baja.** Acceso directo al hardware físico. | **Alta.** El SO anfitrión consume recursos adicionales para gestionar la aplicación. | **Mínima.** Al compartir el kernel, la penalización es casi nula. |
| **Gestión de Memoria (Overcommit / Ballooning)** | **Avanzada y robusta.** Asignación flexible mediante técnicas como *ballooning*. | **Limitada / Dependiente.** Depende de la gestión de memoria del SO anfitrión. | **Dinámica por límites.** Controlada por cgroups del kernel de forma muy ligera. |
| **Soporte de Almacenamiento Compartido** | **Nativo y empresarial.** Compatible con SAN, NAS, iSCSI, NFS y sistemas en clúster. | **Limitado.** Generalmente depende de las unidades compartidas del SO anfitrión. | **Flexible mediante volúmenes.** Montaje de volúmenes persistentes y bind mounts. |
| **Rendimiento de Red** | **Alto rendimiento.** Soporta SR-IOV, conmutadores virtuales dedicados y teaming. | **Enrutado / Tradicional.** Atraviesa la pila de red del SO anfitrión (NAT o Bridge). | **Virtualización ligera.** Interfaces virtuales (veth pairs) con mínima latencia. |

---

## 3. Estructura de la Carpeta

```text
Unidad_5/
└── Tarea_5.1/
    ├── README.md               <-- Documentación técnica de la actividad
    └── diagramas/              <-- (Opcional) Capturas o esquemas de arquitecturas