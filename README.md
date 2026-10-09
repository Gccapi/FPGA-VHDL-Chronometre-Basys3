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

## Utilisation & Synthèse sous Vivado

1. **Création du projet :** Ouvrez Xilinx Vivado et créez un projet ciblant la carte **Digilent Basys 3** (`XC7A35T-1CPG236C`).
2. **Ajout des sources :**
   - Ajoutez `countled.vhd` dans les **Design Sources**.
   - Ajoutez `countled_hd.xdc` dans les **Constraints**.
3. **Flux de conception :**
   - Lancez la **Synthesis**.
   - Lancez l'**Implementation**.
   - Générez le fichier **Bitstream** (`.bit`).
4. **Programmation :** Connectez la carte en USB et téléversez le bitstream via le **Hardware Manager**.

---

## Matériel & Outils Utilisés

- **Carte FPGA :** Digilent Basys 3 (Xilinx Artix-7)
- **Environnement de développement :** AMD / Xilinx Vivado (VHDL-2002/2008)
- **Langage :** VHDL

---

## Auteur

- **Florian ALAUX** 
