# 🔍 FiveM Backdoor Scanner

## 📌 Contexte

Depuis la montée en popularité des ressources unlock / fxap, beaucoup de scripts circulent sans réelle vérification. Certaines personnes en ont profité pour intégrer différentes backdoors directement dans des ressources partagées, revendues ou leakées.

Résultat : de nombreux serveurs se sont retrouvés infectés sans le savoir. Dans certains cas, les backdoors permettaient l’exécution de commandes à distance, le vol de données, la prise de contrôle du serveur ou encore l’installation d’autres scripts malveillants.  
Ce problème est toujours présent aujourd’hui.

Ce projet est né d’un besoin simple : avoir un outil fiable pour analyser ses ressources et éviter de faire tourner du code compromis sur un serveur FiveM.

---

## 🕒 Historique du projet

À la base, ce script était un **scanner dédié uniquement à la backdoor Cipher**, développé en 2023 pour un usage interne.

Avec le temps, de nouvelles variantes sont apparues, les méthodes ont évolué, et l’ancien scanner n’était plus suffisant. J’ai donc décidé de le reprendre entièrement, de le mettre à jour et de l’élargir pour en faire un scanner plus polyvalent capable de détecter plusieurs types de backdoors et de comportements suspects.

Une grande partie du code a été réécrite, optimisée et adaptée aux usages actuels.

---

## 🎯 Objectif du projet

L’objectif n’est pas de faire un outil “magique”, mais un vrai support pour :

- Identifier rapidement des fichiers suspects dans vos ressources.
- Détecter des signatures connues de backdoors.
- Repérer des patterns dangereux ou anormaux.
- Aider à auditer un serveur avant mise en production.
- Limiter la propagation de scripts infectés.

Ce scanner est pensé comme un outil de prévention et d’analyse.

---

## ⚙️ Fonctionnalités

- Scan automatique de dossiers de ressources.
- Détection par signatures et mots-clés.
- Analyse de patterns de code suspects.
- Affichage clair des fichiers détectés.
- Possibilité d’ajouter facilement de nouvelles signatures.
- Compatible avec les structures classiques de serveurs FiveM.

---

## 📥 Installation

```bash
git clone https://github.com/VOTRE_PSEUDO/FiveM-Backdoor-Scanner.git
cd FiveM-Backdoor-Scanner
