# 🚀 Galion DevOps - AWS Infrastructure Deployment

![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?style=for-the-badge&logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge&logo=amazonaws)
![Ansible](https://img.shields.io/badge/Ansible-Automatisation-EE0000?style=for-the-badge&logo=ansible)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?style=for-the-badge&logo=githubactions)
![Checkov](https://img.shields.io/badge/Sécurité-Checkov-4CAF50?style=for-the-badge)

---

# 📌 Description

Projet DevOps d'automatisation complète du déploiement d'une infrastructure Cloud AWS.

Ce projet met en œuvre une chaîne CI/CD permettant de :

- ☁️ Provisionner automatiquement une infrastructure AWS avec **Terraform**
- 🔒 Sécuriser le code Infrastructure as Code avec **Checkov**
- ⚙️ Configurer automatiquement les serveurs avec **Ansible**
- 🌐 Déployer un serveur Web Apache sur une instance EC2
- 🧪 Effectuer des tests automatiques après le déploiement
- 📊 Générer un rapport consolidé dans GitHub Actions

L'objectif est de reproduire un workflow DevOps professionnel allant du code source jusqu'à une infrastructure fonctionnelle en production, tout en appliquant les bonnes pratiques d'automatisation, de sécurité et de déploiement continu.

---

# 🎯 Objectifs du projet

Ce projet a été réalisé afin de démontrer la mise en œuvre d'une chaîne DevOps complète permettant de :

- Automatiser le déploiement d'une infrastructure Cloud AWS
- Mettre en œuvre les principes d'Infrastructure as Code (IaC)
- Détecter les vulnérabilités avant le déploiement grâce à Checkov
- Configurer automatiquement les serveurs avec Ansible
- Déployer une application Web sans intervention manuelle
- Vérifier automatiquement le bon fonctionnement du serveur
- Générer un rapport d'exécution du pipeline CI/CD

---

# 🏗️ Architecture globale

```text
                     Développeur
                          │
                          │ Git Push
                          ▼
                  Dépôt GitHub
                          │
                          ▼
            GitHub Actions CI/CD Pipeline
                          │
         ┌────────────────┼────────────────┐
         │                │                │
         ▼                ▼                ▼
 Validation        Analyse Checkov     Tests
 Terraform          Sécurité
         │
         ▼
 Terraform Apply
         │
         ▼
 Infrastructure AWS
         │
         ▼
 Instance EC2
 Amazon Linux 2023
         │
         ▼
 Configuration Ansible
         │
         ▼
 Apache HTTP Server
         │
         ▼
 Dashboard Galion DevOps
```

---

# 🛠️ Technologies utilisées

## ☁️ Cloud

- Amazon Web Services (AWS)
- EC2
- VPC
- Security Groups
- S3

## 🏗️ Infrastructure as Code

- Terraform

## ⚙️ Configuration

- Ansible

## 🔄 CI/CD

- GitHub Actions

## 🔐 Sécurité

- Checkov

## 🖥️ Système

- Amazon Linux 2023

## 🌐 Serveur Web

- Apache HTTP Server

---

# 📂 Structure du projet

```text
galion-devops/
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       └── webserver/
│           ├── files/
│           │   ├── index.html
│           │   ├── style.css
│           │   └── script.js
│           ├── handlers/
│           │   └── main.yml
│           └── tasks/
│               └── main.yml
│
├── modules/
│   └── aws/
│       ├── ec2/
│       ├── s3/
│       └── vpc/
│
├── .checkov.yml
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
├── variables.tf
└── README.md
```

---

# 🔄 Pipeline CI/CD

À chaque **Push** sur la branche `master`, GitHub Actions exécute automatiquement le pipeline suivant :

## ✅ Étape 1 — Validation Terraform

Les fichiers Terraform sont analysés afin de vérifier :

- Le format du code (`terraform fmt`)
- La syntaxe (`terraform validate`)
- L'initialisation des providers (`terraform init`)

---

## 🔒 Étape 2 — Analyse de sécurité

Le projet utilise **Checkov** afin de détecter les mauvaises pratiques de sécurité dans les fichiers Terraform.

Exemples de contrôles réalisés :

- Configuration des Security Groups
- Paramètres des ressources AWS
- Vérification des bonnes pratiques IaC
- Recherche de vulnérabilités connues

---

## ☁️ Étape 3 — Déploiement AWS

Terraform déploie automatiquement les ressources suivantes :

- VPC
- Subnet
- Internet Gateway
- Route Table
- Security Group
- Instance EC2
- Bucket S3

Aucune création manuelle n'est nécessaire.

---

## ⚙️ Étape 4 — Configuration automatique avec Ansible

Une fois l'infrastructure créée, Ansible prend le relais afin de :

- Installer Apache HTTP Server
- Démarrer le service Apache
- Activer le démarrage automatique
- Déployer le Dashboard Web
- Configurer le serveur Amazon Linux

---

## 🧪 Étape 5 — Tests automatiques

Après le déploiement, GitHub Actions vérifie automatiquement :

- La disponibilité du serveur Web
- Le bon fonctionnement d'Apache
- La présence du contenu attendu sur la page

Si un test échoue, le pipeline est interrompu.

---

## 📊 Étape 6 — Rapport final

À la fin de l'exécution, GitHub Actions génère automatiquement un résumé contenant :

- Résultat de Terraform
- Résultat de Checkov
- Résultat du déploiement
- Résultat d'Ansible
- Résultat des tests

Le rapport est disponible dans l'onglet **Summary** de GitHub Actions.

---

# 🚀 Déploiement manuel

## Prérequis

Installer les outils suivants :

- Terraform
- AWS CLI
- Ansible
- Git

---

## Configuration AWS

```bash
aws configure
```

---

## Initialisation Terraform

```bash
terraform init
```

---

## Validation

```bash
terraform validate
```

---

## Déploiement

```bash
terraform apply
```

---

## Configuration Ansible

```bash
cd ansible
ansible-playbook playbook.yml
```

---

# 🌐 Résultat

Une fois le déploiement terminé, le Dashboard est accessible depuis l'adresse IP publique de l'instance EC2 :

```text
http://PUBLIC_IP_EC2
```

Le Dashboard affiche notamment :

- 🚀 Galion DevOps
- Cloud Infrastructure Deployment
- Terraform AWS
- Apache Web Server
- Ansible Automation
- Pipeline CI/CD
- Informations sur le serveur
- Date et heure du déploiement

---

# 📸 Captures d'écran

Vous pouvez ajouter ici les captures de votre projet :

## Dashboard Web

```text
docs/images/dashboard.png
```

## Pipeline GitHub Actions

```text
docs/images/github-actions.png
```

## Résumé GitHub Actions

```text
docs/images/workflow-summary.png
```

Ces captures permettront d'illustrer le fonctionnement complet du projet directement depuis GitHub.

---

# 📈 Compétences mises en œuvre

Ce projet m'a permis de mettre en pratique les compétences suivantes :

### ☁️ Cloud Computing

- Amazon Web Services (AWS)
- EC2
- VPC
- Security Groups
- S3

### 🏗️ Infrastructure as Code

- Terraform
- Modules Terraform
- Variables
- Outputs
- Providers

### ⚙️ Configuration Management

- Ansible
- Playbooks
- Roles
- Inventory
- Gestion des services Linux

### 🚀 CI/CD

- GitHub Actions
- Déploiement automatique
- Validation continue
- Tests automatiques

### 🔒 Sécurité

- Checkov
- Analyse Infrastructure as Code
- Bonnes pratiques AWS

### 🖥️ Administration Système

- Amazon Linux 2023
- Apache HTTP Server
- SSH
- Gestion des permissions Linux

---

# 🎯 Résultats obtenus

À l'issue du projet, le pipeline est capable de :

✅ Valider automatiquement le code Terraform

✅ Vérifier la sécurité de l'infrastructure avec Checkov

✅ Déployer automatiquement une infrastructure AWS

✅ Configurer automatiquement le serveur avec Ansible

✅ Déployer une application Web moderne

✅ Vérifier automatiquement le bon fonctionnement du serveur

✅ Générer un rapport complet d'exécution dans GitHub Actions

L'ensemble du processus est entièrement automatisé et reproductible.

---

# 🔮 Améliorations futures

Les évolutions envisagées pour ce projet sont :

- [ ] Utilisation d'un backend Terraform distant (S3 + DynamoDB)
- [ ] Authentification GitHub Actions via AWS OIDC
- [ ] Déploiement Multi-Environnements (Dev / Test / Production)
- [ ] Mise en place d'un Application Load Balancer
- [ ] Déploiement HTTPS avec AWS Certificate Manager
- [ ] Surveillance avec Amazon CloudWatch
- [ ] Monitoring avec Grafana et Prometheus
- [ ] Déploiement avec Docker
- [ ] Orchestration avec Kubernetes (EKS)
- [ ] Déploiement Multi-Cloud (AWS / Azure / GCP)

---

# 📚 Références

Documentation officielle :

- Terraform
- Ansible
- GitHub Actions
- AWS
- Checkov

---

# 👨‍💻 Auteur

**Junior Galion**

Étudiant en Réseaux, Télécommunications & Cloud Computing

Passionné par :

- DevOps
- Cloud Computing
- Infrastructure as Code
- Automatisation
- Cybersécurité
- Réseaux

---

# ⭐ Remerciements

Merci d'avoir consulté ce projet.

Si ce dépôt vous a été utile ou intéressant, n'hésitez pas à lui attribuer une ⭐ sur GitHub.

---

# 📄 Licence

Ce projet est distribué à des fins pédagogiques et de démonstration.

© 2026 Junior Galion