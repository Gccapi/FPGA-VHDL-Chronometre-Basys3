# FPGA-VHDL-Chronometre-Basys3
Chronomètre numérique au 1/100e de seconde en VHDL sur carte Xilinx Artix-7 (Basys 3) sous Vivado.

##  Description du projet
Ce projet consiste en la conception et l'implémentation d'un chronomètre numérique de précision sur la carte d'évaluation **Digilent Basys 3** (FPGA Xilinx Artix-7 XC7A35T). 

Le système gère l'affichage dynamique multiplexé sur 4 afficheurs 7 segments et intègre une gestion complète du contrôle de chronométrage via les boutons poussoirs de la carte.

---

## Fonctionnalités
- **Précision temporelle :** Génération d'une horloge interne de 100 Hz à partir de l'horloge système de 100 MHz.
- **Affichage multiplexé :** Gestion dynamique des 4 digits 7 segments (Dizaines de secondes, Unités de secondes, Dixièmes, Centièmes) sans effet de clignotement.
- **Contrôle utilisateur (Machine à états / Logique séquentielle) :**
  - **Start / Reprise :** Bouton `BTNU` (anti-rebond synchronisé)
  - **Pause :** Bouton `BTND` (anti-rebond synchronisé)
  - **Reset :** Bouton `BTNC` avec retour visuel sur les LEDs

---

## Architecture du Dépôt

```text
.
├── countled.vhd        # Code source VHDL principal (Architecture & Entité)
├── countled_hd.xdc     # Fichier de contraintes matérielles pour Basys 3
└── README.md           # Documentation du projet
