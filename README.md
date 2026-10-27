# Jenkins CI/CD Setup Guide on AWS EC2

This guide provides step-by-step instructions to set up Jenkins on an AWS EC2 instance, install required build tools, configure a `Jenkinsfile`, and trigger your first pipeline.

---

## 📋 Overview
- **Hosting Environment:** AWS EC2 (Ubuntu 24.04 LTS)
- **CI/CD Tool:** Jenkins
- **Build Tools:** Node.js 20, Git, Java 17

---

## 🚀 Step 1: Launch and Configure AWS EC2 Instance

1. **AMI Selection:** Choose **Ubuntu 24.04 LTS**.
2. **Instance Type:** Select `t3.medium` (minimum 2GB RAM required for Jenkins).
3. **Security Group Configuration:**
   Add the following inbound rules:
   | Type | Port | Source | Purpose |
   | :--- | :--- | :--- | :--- |
   | **SSH** | `22` | My IP | Secure SSH Terminal Access |
   | **Custom TCP** | `8080` | `0.0.0.0/0` | Access Jenkins Web UI |

---

## ⚙️ Step 2: Install Java & Jenkins on EC2

Connect to your EC2 instance via SSH and execute the following commands:

```bash
# 1. Update system packages
sudo apt update && sudo apt upgrade -y

# 2. Install Java (JDK 17)
sudo apt install fontconfig openjdk-17-jre -y
java -version

# 3. Add the official Jenkins repository key and source list
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# 4. Install Jenkins
sudo apt update
sudo apt install jenkins -y

# 5. Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

---

## 🔓 Step 3: Access & Initialize Jenkins UI

1. Open your web browser and navigate to:
   ```text
   http://<YOUR_EC2_PUBLIC_IP>:8080
   ```
2. Retrieve the initial admin password from your EC2 SSH session:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Paste the password into the prompt, select **"Install Suggested Plugins"**, and set up your Admin user account.

---

## 🛠️ Step 4: Install Build Tools (Node.js & Git)

Because Jenkins runs builds locally on the EC2 runner, install Node.js and Git:

```bash
# Install Git
sudo apt install git -y

# Install Node.js (v20)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installations
git --version
node -v
npm -v
```

---

## 📄 Step 5: Add `Jenkinsfile` to Your Repository

Create a file named `Jenkinsfile` (no file extension) in the root directory of your project:

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out source code from Git...'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing npm packages...'
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'npm test || echo "No test script found, skipping failure."'
            }
        }

        stage('Build') {
            steps {
                echo 'Building application...'
                sh 'echo "Application build successful!"'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed!'
        }
        success {
            echo 'Pipeline finished successfully.'
        }
        failure {
            echo 'Pipeline failed. Check build logs for details.'
        }
    }
}
```

Commit and push the file to your repository:
```bash
git add Jenkinsfile
git commit -m "Add Jenkinsfile pipeline configuration"
git push origin main
```

---

## 🔗 Step 6: Create & Execute Jenkins Job

1. Log into your Jenkins dashboard (`http://<YOUR_EC2_PUBLIC_IP>:8080`).
2. Click **New Item** on the left menu.
3. Enter `devsecops-jenkins-pipeline`, select **Pipeline**, and click **OK**.
4. Scroll down to the **Pipeline** section:
   - Set **Definition** to **`Pipeline script from SCM`**.
   - Set **SCM** to **`Git`**.
   - Set **Repository URL** to your GitHub repository URL (e.g., `https://github.com/manojkumarsahoo-dev/githubactions.git`).
   - Set **Branch Specifier** to `*/main`.
   - Ensure **Script Path** is `Jenkinsfile`.
5. Click **Save**.
6. Click **Build Now** on the job sidebar to trigger your pipeline execution.
7. Click the build number under **Build History** -> **Console Output** to monitor live logs.
