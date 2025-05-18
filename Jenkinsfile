pipeline {
    agent any

    environment {
        TF_WORKDIR = 'terraform'      // folder with your Terraform files
        ANSIBLE_DIR = 'ansible'       // folder with your Ansible files
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir("${TF_WORKDIR}") {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Prepare SSH Key') {
            steps {
                withCredentials([file(credentialsId: 'my-ssh-key-id', variable: 'SSH_KEY')]) {
                    sh """
                        mkdir -p ${ANSIBLE_DIR}
                        cp \$SSH_KEY ${ANSIBLE_DIR}/mykey.pem
                        chmod 600 ${ANSIBLE_DIR}/mykey.pem
                    """
                }
            }
        }

        stage('Update Inventory') {
            steps {
                script {
                    def ec2_ip = sh(script: "terraform -chdir=${TF_WORKDIR} output -raw public_ip", returnStdout: true).trim()
                    writeFile file: "${ANSIBLE_DIR}/inventory.ini", text: "[web]\n${ec2_ip} ansible_user=ec2-user ansible_ssh_private_key_file=mykey.pem\n"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sh """
                    ansible-playbook -i ${ANSIBLE_DIR}/inventory.ini ${ANSIBLE_DIR}/playbook.yml --private-key=${ANSIBLE_DIR}/mykey.pem
                """
            }
        }
    }
}
