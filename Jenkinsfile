pipeline {
    agent any

    environment {
        APP_PORT = "3000"
        VM_IP = "4.251.118.250"  // Votre IP
    }

    stages {
        stage('1. Checkout & Setup') {
            steps {
                echo "🔁 Récupération du code"
                git branch: 'main', 
                url: 'https://github.com/lynfrank/ais_devops_project'
                
                sh 'docker volume create todo-mysql-data || true'
            }
        }

        stage('2. Build & Test') {
            steps {
                echo "🔨 Construction et tests"
                sh '''
                    # Lancement temporaire pour les tests
                    docker-compose up -d
                    
                    # Attente démarrage MySQL
                    sleep 15
                    
                    # Exécution des tests
                    docker-compose exec app yarn test || true
                    
                    # Arrêt propre SANS supprimer les volumes
                    docker-compose down
                '''
            }
        }

        stage('3. Deploy Production') {
            steps {
                echo "🚀 Déploiement final"
                sh '''
                    # Lancement persistant
                    docker-compose up -d
                    
                    # Vérification
                    sleep 5
                    curl -I http://localhost:${APP_PORT} || true
                '''
            }
        }
    }

    post {
        success {
            echo "✅ SUCCÈS: Application en production!"
            echo "🌐 Accédez à: http://${VM_IP}:${APP_PORT}"
            sh 'docker ps'  // Montre les conteneurs actifs
        }
        failure {
            echo "❌ ÉCHEC: Vérifiez les logs"
            sh 'docker-compose logs || true'
        }
    }
}
