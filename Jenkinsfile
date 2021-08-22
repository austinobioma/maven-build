pipeline {
    agent any

    stages {
        stage('Git checkout') {
            steps {
                git 'https://github.com/austinobioma/java-project.git'
            }
        }
      stage('Build') {
            steps {
               sh 'cd MyWebApp && mvn clean  package'
            }
        }
      stage('Test') {
            steps {
                sh 'cd MyWebApp && mvn test'
            }
        }
      stage('Deploy to tomcat') {
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'tomcat-server', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'ansible-playbook -i hosts myplaybook.yml --limit ubuntu@54.242.174.212', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '.', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '**/*.war')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
        }
    }
          
}
