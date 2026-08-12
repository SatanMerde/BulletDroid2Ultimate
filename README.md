# BulletDroid2Ultimate 🚀

**BulletDroid2Ultimate** est une version grandement améliorée et optimisée du projet original [BulletDroid2](https://github.com/DannyLuna17/BulletDroid2) (lui-même un portage mobile d'OpenBullet).

> **Note importante** : L'intégralité des améliorations, des nouvelles fonctionnalités (dont le support multi-formats), des corrections de bugs et des audits de sécurité de cette version "Ultimate" ont été réalisés **exclusivement par une Intelligence Artificielle (IA)**. 

---

## 🌟 Nouveautés de la version Ultimate

- **Support Multi-Formats** : Accepte nativement les formats `.loli`, `.svb` (SilverBullet), `.anom` (Anomaly) et `.opk` (OpenBullet Pack). Plus besoin de convertir manuellement vos configurations !
- **Audit de Sécurité Complet** : L'application a été entièrement vérifiée. Aucun tracking, aucune télémétrie, et aucune exfiltration de données. Une application 100% sûre pour l'utilisateur.
- **Corrections de Bugs** : De nombreux correctifs invisibles à l'œil nu ont été appliqués (amélioration du parser, fix sur la casse des tags, meilleure gestion des ressources en arrière-plan, etc.).
- **Nouvelle Identité** : Renommage complet et refonte des détails internes pour une expérience plus fluide.

---

## ⚖️ Droits Légaux & Avertissements

- **Création IA** : Ce fork a été généré et amélioré par l'intelligence artificielle. 
- **Droits et Héritage** : BulletDroid2Ultimate est basé sur le travail de *DannyLuna17* (BulletDroid2) et s'inspire du logiciel original *OpenBullet*. Les droits des créateurs originaux s'appliquent.
- **Responsabilité** : Ce logiciel est fourni "tel quel", dans un but purement éducatif et pour tester la sécurité de vos propres systèmes. L'auteur (ainsi que l'IA) déclinent toute responsabilité quant à l'utilisation malveillante ou illégale qui pourrait être faite de cet outil. L'utilisateur est seul responsable de ses actes.

---

## 🐛 Bugs et Suggestions

Puisque cette version a été conçue par une IA, il se peut que certaines choses puissent être encore améliorées ou affinées.

- **Vous avez trouvé un bug ?** 
- **Vous souhaitez une nouvelle fonctionnalité ?**

N'hésitez pas à ouvrir une **Issue** directement sur ce dépôt GitHub (https://github.com/SatanMerde/BulletDroidUltimate). Décrivez votre problème ou votre idée, et l'IA (ou la communauté) pourra s'en charger lors de la prochaine mise à jour !

---

## 🛠️ Installation & Compilation

(Pour les développeurs souhaitant compiler l'application eux-mêmes)

1. Assurez-vous d'avoir [Flutter](https://flutter.dev/) installé (SDK 3.8.1 ou plus récent).
2. Clonez le dépôt :
   ```bash
   git clone https://github.com/SatanMerde/BulletDroidUltimate.git
   ```
3. Naviguez dans le dossier de l'application :
   ```bash
   cd BulletDroidUltimate/bullet_droid
   ```
4. Récupérez les dépendances et lancez le build :
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter run
   ```
