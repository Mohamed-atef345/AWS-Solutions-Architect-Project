Here’s your updated README with all emojis removed and a clean, professional format retained:

---

````markdown
# AWS Solutions Architect Project

This project automates the deployment of a Jenkins CI/CD server and a Prometheus monitoring server on AWS using Terraform. It provisions the required infrastructure, installs the necessary software, and configures both servers for seamless operation.

---

## Project Overview

This project uses Terraform to deploy and configure:

### 1. Jenkins Server
- Deployed on an AWS EC2 instance.
- Jenkins is installed and exposed on port `8080`.
- Automatically retrieves the initial admin password for login.

### 2. Prometheus Server
- Deployed on a separate AWS EC2 instance.
- Prometheus runs inside Docker and is exposed on port `9090`.
- Uses a custom configuration file (`prometheus.yml`).

### 3. Infrastructure Components
- A VPC with a subnet, internet gateway, and security groups.
- Latest Ubuntu AMI is fetched dynamically.
- SSH access configured via a shared key pair.

---

## Project Structure

```plaintext
├── main.tf
├── outputs.tf
├── modules/
│   └── server_module/
│       ├── main.tf
│       ├── variables.tf
│       └── output.tf
├── scripts/
│   ├── install_java_jenkins.sh
│   └── install_docker_prometheus.sh
├── config_files/
│   └── prometheus.yml
└── README.md
````

---

## Key Components

| Component                     | Description                                                   |
| ----------------------------- | ------------------------------------------------------------- |
| `main.tf`                     | Defines the main infrastructure and module instantiations.    |
| `outputs.tf`                  | Outputs the public IPs and Jenkins admin password.            |
| `modules/server_module`       | A reusable module for EC2 provisioning.                       |
| `scripts/`                    | Bash scripts to install and configure Jenkins and Prometheus. |
| `config_files/prometheus.yml` | Prometheus scrape configuration.                              |

---

## Features

### Jenkins Server

* Installs Java and Jenkins via script.
* Opens port `8080` for web interface.
* Outputs the initial admin password for setup.

### Prometheus Server

* Installs Docker and Prometheus via script.
* Uses custom `prometheus.yml` for configuration.
* Exposes Prometheus on port `9090`.

### Infrastructure Automation

* Full Infrastructure as Code using Terraform.
* Provisions networking and security resources.
* Uses latest Ubuntu image dynamically.

---

## Prerequisites

Ensure the following are installed and configured:

* [Terraform](https://developer.hashicorp.com/terraform/downloads)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) with valid credentials
* SSH key pair located at:

  * Private key: `~/.ssh/deployer`
  * Public key: `~/.ssh/deployer.pub`

---

## Usage

1. **Clone the Repository**:

   ```bash
   git clone <repository-url>
   cd AWS-Solutions-Architect-Project
   ```

2. **Initialize Terraform**:

   ```bash
   terraform init
   ```

3. **Deploy the Infrastructure**:

   ```bash
   terraform apply
   ```

4. **Access Jenkins**:

   * Visit `http://<jenkins_public_ip>:8080`
   * Use the admin password from Terraform output.

5. **Access Prometheus**:

   * Visit `http://<prometheus_public_ip>:9090`

---

## Outputs

* `Jenkins Admin Password`: Used for the initial login.
* `Jenkins Public IP`: EC2 public address.
* `Prometheus Public IP`: EC2 public address.

---

## File Descriptions

* **`main.tf`**: Core Terraform config for infrastructure and modules.
* **`modules/server_module/`**: Generic server provisioning logic.
* **`install_java_jenkins.sh`**: Jenkins setup script.
* **`install_docker_prometheus.sh`**: Prometheus setup via Docker.
* **`prometheus.yml`**: Prometheus job definitions.

---

## Security Considerations

* `.gitignore` excludes sensitive files like `terraform.tfstate` and Jenkins secrets.
* Security groups limit access to essential ports only.
```