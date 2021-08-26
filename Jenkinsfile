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
     stage ('Code Qualty Scan') {
            steps {
               withSonarQubeEnv('sonar') 
               {
              sh 'mvn -f MyWebApp/pom.xml sonar:sonar'
            }
                }
        }
     stage ('Quality gate') {
            steps {
              waitforQualityGate abortPipeline: true
            }
        }
          stage ('Deploy to tomcat') {

            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'tomcat-server', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'ansible-playbook -i hosts myplaybook.yml --limit ubuntu@54.166.138.252', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '.', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '**/*.war')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                }
            }
          }
}
