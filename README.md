# **📊 GTM Stack com Prometheus**

## **Descrição**

Este repositório contém a configuração da LGTM Stack com Prometheus para Kubernetes, utilizando Helm e Helmfile para implantação, e Terraform para criar os serviços e recursos necessários. A stack inclui serviços como Grafana, Mimir, Prometheus e Tempo, oferecendo uma solução de monitoramento abrangente.

---

## **Arquitetura Integrada da Stack GTM com Prometheus**

A stack LGTM com Prometheus é projetada para funcionar como um sistema integrado, onde cada componente desempenha um papel vital no monitoramento e na análise de dados em ambientes Kubernetes:

- **Grafana**: O centro de controle visual. Não apenas para visualizar métricas, logs e traces, mas também gerenciar alertas e dashboards, oferecendo uma visão unificada do desempenho do sistema.
- **Prometheus**: O coração da coleta de métricas. Ele monitora constantemente os serviços, coletando dados que são fundamentais para a análise de desempenho e saúde do sistema.
- **Mimir**: Funciona como o cérebro do armazenamento de longo prazo para métricas. Ele assegura que os dados coletados pelo Prometheus sejam armazenados de forma segura e eficiente, permitindo análises históricas e escalabilidade.
- **Tempo**: A solução para tracing distribuído, essencial para compreender transações e interações complexas dentro do sistema. Ele coleta e armazena traces de forma eficiente, integrando-se ao Grafana para uma análise detalhada.

Cada componente é essencial e trabalha em conjunto para oferecer uma visão completa e detalhada do ambiente, facilitando o monitoramento, a resolução de problemas e a otimização do desempenho.

![arc-pd.png](https://cdn.discordapp.com/attachments/1095404943663439912/1202669044059340800/arc-pd.png?ex=65ce4bd4&is=65bbd6d4&hm=36f60d393d674a8951242a35a8ed94821872448766aae7cf46ae4da0a63618c6&)
---

## ➕ **Dependências**

- **Kubernetes**
- **Helm**
- **Helmfile**
- **Terraform**

---

## **📋 Pré-Requisitos**

- Instalação do Helm e Helmfile (consulte [este guia](https://www.notion.so/Helm-e7ad4d8009be47a8a9196de221f66d4e?pvs=21) para instruções detalhadas).
- Instalação do Terraform  (consulte [este guia](https://www.notion.so/Instalation-4a494c1fe97649d7af8b0f051f8edb51?pvs=21) para instruções detalhadas).

---
## **Aviso Importante para Ambientes de Produção**

Para garantir a máxima eficiência e segurança em ambientes de produção, é fortemente recomendado a utilização de um node pool dedicado exclusivamente para a stack em questão, ou, alternativamente, a configuração de um cluster completamente separado. Essa medida assegura o isolamento adequado dos recursos e otimiza a performance do sistema.

---

# **Configuração Inicial com Terraform**

Antes de prosseguir com a implantação da GTM Stack via Helmfile, é essencial configurar a infraestrutura AWS com Terraform. Este processo cria roles OIDC, políticas IA e buckets S3 necessários para os serviços Tempo e Mimir.1

## **Configuração do Terraform**

1. **Provedor AWS**:
Defina o **`provider`** para especificar o perfil e a região da AWS.
2. **EKS Cluster**:
Utilize **`data`** para recuperar informações do seu cluster EKS existente.
3. **Buckets S3**:
    - **`module "s3-tempo"`** e **`module "s3-mimir"`** criam buckets S3 para armazenar dados do Tempo e Mimir, respectivamente.
4. **Roles OIDC e Políticas IAM**:
    - **`module "iam-tempo"`** e **`module "iam-mimir"`** configuram roles IAM com políticas que permitem acesso aos buckets S3 correspondentes.

## **Configuração do Backend para Produção**:

Para ambientes de produção, é recomendado configurar o Terraform para usar um bucket S3 como backend, adicionando o seguinte bloco no arquivo **`versions.tf`**:

```yaml
terraform {
  backend "s3" {
    bucket  = "SEU_BUCKET"
    key     = "tfstate"
    region  = "SUA_REGIAO"
    profile = "SEU_PROFILE"
  }
}
```

## **Aplicando o Terraform**

- Inicialize o Terraform:
    
    ```bash
    terraform init
    ```
    
- Planeje as alterações:
    
    ```bash
    terraform plan
    ```
    
- Aplique a configuração:
    
    ```bash
    terraform apply
    ```
    
- Para desfazer a infraestrutura, se necessário:
    
    ```bash
    terraform destroy
    ```
    

## **Outputs do Terraform**

Os outputs **`iam-mimir-arn`** e **`iam-tempo-arn`** serão gerados. Inclua esses ARNs nas annotations do Helm para Mimir e Tempo, garantindo a correta autorização de acesso aos recursos AWS.

Inclua os ARNs fornecidos nas annotations dos Helms do Mimir e do Tempo, como mostrado abaixo:

```yaml
annotations:
  eks.amazonaws.com/role-arn: arn:aws:iam::<ID_DO_SEU_ACCOUNT>:role/<ROLE_NAME>
```

---

## **Configuração dos Serviços: Mimir e Tempo**

A stack GTM dispõe de configurações flexíveis para os serviços Mimir e Tempo, projetadas para se adaptar a diferentes volumes de dados e requisitos de retenção. 

**Os values ainda estão em revisão!**

- **Mimir**: **`small.yaml`** suporta até 1 milhão de métricas com 30 dias de retenção, **`large.yaml`** para até 10 milhões de métricas com 30 dias de retenção.
- **Tempo**: **`small.yaml`** acomoda até 1 milhão de traços com 7 dias de retenção, **`large.yaml`** para até 10 milhões de traços com 7 dias de retenção.

As definições para cada um desses serviços são facilmente gerenciáveis através do arquivo **`helmfile.yaml`**. Para ativar uma configuração específica, basta descomentar a linha correspondente ao arquivo **`small.yaml`** ou **`large.yaml`** desejado.

Para ambientes de teste ou desenvolvimento, recomenda-se utilizar as configurações padrão, que já são suficientes para a maioria dos cenários de laboratório.

## 🔧 **Instalação da Stack GTM**

1. Clone o repositório:
    
    ```bash
    git clone git@github.com:leozw/gtm-stack.git
    ```
    
2. Navegue até o diretório e execute:
    
    ```bash
    helmfile apply
    ```
    
    para instalar a stack.
    

## 💡 **Atualizações e Manutenção**

- Para atualizar a stack, execute:
    
    ```bash
     helmfile sync
    ```
    
- Para remover toda a stack, use:
    
    ```bash
     helmfile delete
    ```
    
- Para remover um serviço específico, use:
    
    ```bash
     helm uninstall [release_name] -n lgtm
    ```
    

Após a remoção, o mesmo deverá ser removido do `helmfile.yaml`, para manter a consistência.

---

## **Acessando o Grafana**

Para visualizar as métricas e consultar dados do Mimir e Tempo (caso tenha traces), você pode usar o port-forward para acessar a interface do Grafana:

1. Execute o comando abaixo para criar um port-forward para o Grafana:
    
    ```bash
    kubectl port-forward svc/grafana 3000:80 -n lgtm
    ```
    
    Isso tornará o Grafana acessível em **`localhost:3000`** no seu navegador.
    
2. Para obter a senha padrão do Grafana, use o seguinte comando:
    
    ```bash
    kubectl get secret -n lgtm grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```
    
    Use este comando para recuperar a senha de administração do Grafana.
    
3. Acesse o Grafana em seu navegador e use as credenciais de administração para fazer login.
O usuário default é `admin`.
Explore as métricas disponíveis e faça consultas para validar os dados do Mimir.

---

## **Armazenamento de Objetos para Mimir e Tempo**

Nossa LGTM Stack utiliza o MinIO como solução padrão de armazenamento de objetos para Mimir e Tempo. Entretanto, é totalmente viável substituir o MinIO por outras opções de armazenamento de objetos que sejam compatíveis. As alternativas incluem:

- AWS S3
- Google Cloud Storage
- Azure Blob Storage
- Qualquer sistema compatível com a API S3

Para integrar Mimir e Tempo com um sistema de armazenamento alternativo, como o AWS S3, é necessário adaptar as configurações nos respectivos arquivos de valores. Providenciamos um exemplo de como configurar a conexão com o AWS S3 no repositório. Ajuste as credenciais e outras configurações específicas de acordo com o seu provedor de armazenamento.

Quando optar por utilizar os arquivos de configuração **`small.yaml`** e **`large.yaml`**, recomendamos fortemente o uso de um Cloud Object Store como o AWS S3 ou o Google Cloud Storage, em vez do MinIO, para garantir melhor desempenho e escalabilidade.

---

---

## **Requisitos do Cluster/NodePool**

Para implantar esta stack com eficiência, é importante considerar os requisitos de recursos do cluster ou nodepool. Os valores a seguir representam o uso base da stack, mas é importante notar que, ao utilizar arquivos de recursos adicionais para o Mimir, Loki e Tempo, os requisitos de recursos podem aumentar significativamente.

É recomendável avaliar cuidadosamente as necessidades de CPU, memória e armazenamento, ajustando o Cluster ou NodePool de acordo com essas demandas. Esta avaliação ajudará a garantir que a stack opere de forma estável e eficiente.

![resoruces](https://media.discordapp.net/attachments/890968993110839316/1201618437269618779/image.png?ex=65ca7960&is=65b80460&hm=eea4a4af6ca50617bc60f4873905e1f615cbcb8c578cd875e3e6ca048989f4e3&=&format=webp&quality=lossless&width=774&height=468)

---

## **Estrutura do Repositório**

O repositório está estruturado com diretórios para cada serviço (Grafana, Loki, Mimir, Prometheus, Promtail, Tempo), cada um contendo seus respectivos valores de configuração e arquivos de template Helm.

---

## **Contribuições**

@Emerson Cesario
