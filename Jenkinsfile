pipeline {
    agent any

    environment {
        TF_DIR = 'terraform'
        ANSIBLE_PLAYBOOK = 'ansible/playbook.yml'
        PUBLIC_IP_FILE = 'public_ip.txt'
        HOSTS_FILE = 'hosts.ini'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                        cd ${TF_DIR}
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                        cd ${TF_DIR}
                        terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Do you want to apply the Terraform changes?"
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                        cd ${TF_DIR}
                        terraform apply -auto-approve tfplan

                        # Extract public IP after apply
                        terraform output -raw public_ip > ../${PUBLIC_IP_FILE}
                    '''
                }
            }
        }

        stage('Generate hosts.ini') {
            steps {
                withCredentials([file(credentialsId: 'EC2_SSH_KEY', variable: 'SSH_KEY')]) {
                    sh '''
                        PUBLIC_IP=$(cat ${PUBLIC_IP_FILE})
                        echo "[ec2_instance]" > ${HOSTS_FILE}
                        echo "$PUBLIC_IP ansible_user=ec2-user ansible_ssh_private_key_file=$SSH_KEY" >> ${HOSTS_FILE}
                    '''
                }
            }
        }

        stage('Ansible Ping Test') {
            steps {
                sh '''
                    ansible-playbook -i ${HOSTS_FILE} ${ANSIBLE_PLAYBOOK}
                '''
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
