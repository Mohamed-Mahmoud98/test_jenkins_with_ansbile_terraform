pipeline {
    agent any

    environment {
        TF_DIR = 'terraform'
        ANSIBLE_PLAYBOOK = 'ansible/playbook.yml'
        PUBLIC_IP_FILE = 'public_ip.txt'
        HOSTS_FILE = 'hosts.ini'
        LOCAL_SSH_KEY = 'ec2_key.pem'  // The name of the copied key file
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

        stage('Wait for EC2 to boot') {
            steps {
                echo 'Waiting for EC2 instance to initialize...'
                sleep time: 200, unit: 'SECONDS'  // Wait ~3 minutes 20 seconds
            }
        }

        stage('Generate hosts.ini') {
            steps {
                withCredentials([file(credentialsId: 'EC2_SSH_KEY', variable: 'SSH_KEY')]) {
                    sh '''   
                        echo "Copying SSH key for Ansible usage..."
                        cp $SSH_KEY ${LOCAL_SSH_KEY}
                        chmod 400 ${LOCAL_SSH_KEY}

                        PUBLIC_IP=$(cat ${PUBLIC_IP_FILE})
                        echo "[ec2_instance]" > ${HOSTS_FILE}
                        echo "$PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=${LOCAL_SSH_KEY} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ${HOSTS_FILE}
                    '''
                }
            }
        }

        stage('Ansible install nginx') {
            steps {
                sh '''
                    echo "Running Ansible playbook..."
                    ansible-playbook -i ${HOSTS_FILE} ${ANSIBLE_PLAYBOOK}
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace and SSH key...'
            sh 'rm -f ${LOCAL_SSH_KEY}'
            cleanWs()
        }
    }
}
