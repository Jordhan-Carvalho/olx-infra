# Desafio Infra OLX

## Geral
O arquivo `terraform.tfstate` é salvo em um bucket criado manualmente.
As variáveis estão sendo criadas em um arquivo `terraform.tfvars` sem serem commitadas.
Inicialmente, deixei o bucket do S3 público para acompanhar o desenho da arquitetura do desafio, que permite que o usuário acessasse o bucket diretamente. No entanto, após realizar algumas pesquisas, vi que era mais recomendado restringir o acesso ao bucket e permitir que o usuário acesse apenas o CDN do CloudFront.

## Estrutura do projeto
O projeto está dividido da seguinte maneira:

- `cloudfront`: Contém as configurações e infraestrutura necessárias para o CDN.
- `s3`: Contém as configurações para a criação do bucket do frontend.
- `autoscaling`: Contém toda a infraestrutura e lógica necessárias para escalar a aplicação web, incluindo AWS Autoscaling, EC2, ELB e CloudWatch.
- `rds`: Contém e configurações para a criação do banco de dados.
- `provider`: Contém a configuração dos plugins utilizados e o backend para o acesso ao tfstate.
- `variables`: Declaração das variáveis usadas no projeto.
- `outputs`: Outputs.

## Pontos a melhorar
Devido ao tempo, alguns pontos planejados ficaram de fora, como:

### VPC e Security Groups
Foi utilizado a VPC padrão criada automaticamente, e os security groups padrão para EC2 e ELB. Seria uma boa ideia gerenciar tudo no Terraform.

### Domínio próprio
Seria interessante utilizar o Route53 e o Certificate Manager para um domínio próprio.

### Aplicação de teste
Seria recomendável criar uma aplicação de teste simples para verificar a infraestrutura e realizar testes de carga, a fim de avaliar o funcionamento do autoscaling.
