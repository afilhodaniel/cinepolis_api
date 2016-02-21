== README

<b>rails_app</b> é apenas um projeto Rails com algumas configurações e funcionalidades já implementadas.

=== Requerimentos e configurações recomendadas

* Ruby 2.3.0 ou superior
* Rails 4.2.5.1
* {ImageMagick}[http://www.imagemagick.org/]
* {Node.js}[https://nodejs.org]
* {Gulp.js}[http://gulpjs.com/]
* {Bower}[http://bower.io/]

=== Iniciando

Baixe este repositório:

  git clone git@github.com:afilhodaniel/rails_app

Instale todas as dependências nencessárias

  sudo npm install
  bower install

Rode o Gulp.js:
  
  gulp

=== Restful API

O projeto conta com uma API Restful totalmente funcional e versionada, que pode ser evoluída ou substituída conforme as necessidades do seu projeto. Um modelo de usuário também já está configurado como recurso desta API.

Vale a pena ressaltar que esta API só responde requisições feitas em JSON.

<b>Rotas</b>

Por padrão, apenas os métodos <b>index</b>, <b>show</b>, <b>create</b>, <b>update</b> e <b>destroy</b> estarão disponíveis para qualquer recurso controlado pela API.

Crie novas rotas adicionando e/ou aninhando recursos no seu arquivo <b>config/routes.rb</b>:

  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update, :destroy]
    end
  end

Todas as rotas seguem o padrão abaixo (exceto rotas aninhadas):

* GET /api/v1/users.json
* POST /api/v1/users.json
* GET /api/v1/users/:id.json
* PUT/PATCH /api/v1/users/:id.json
* DELETE /api/v1/users/:id.json
  
<b>Controladores</b>

Crie novos controladores dentro do diretório <b>app/controllers/api/v1</b> e estenda a classe <b>BaseController</b>. Veja o arquivo <b>users_controllers.rb</b> como exemplo:

  module Api
    module V1
      class UsersControllers < BaseController
        ...
        private
          def users_params
            ...
          end
          
          def query_params
            ...
          end
      end
    end
  end
  
Todo controlador deve conter o método privado <b><i>resources</i>_params</b> (onde <i>resources</i> é o nome no plural do recurso que está sendo configurado), podendo ou não conter o método privado <b>query_params</b>.

  private
    def users_params
      params.require(:user).permit(:avatar, :name, :bio, :username, :email, :password)
    end
    
    def query_params
      params.permit(:id, :username, :email)
    end

<b>users_params</b>, neste caso, é utilizado para permitir os parâmetros <i>params[:user][:avatar]</i>, <i>params[:user][:name]</i> e assim por diante, nos métodos <b>create</b> e <b>update</b>.

<b>query_params</b>, pode ser usado para criar uma filtragem de resultados no método <b>index</b>.

<b>Paginando resultados</b>

Estamos utilizando a gem {kaminari}[https://github.com/amatsuda/kaminari] para paginar resultados no método <b>index</b>.

Para paginar resultados, utilize na requisição:

* GET /api/v1/users.json?page=1&page_size=5

E na <i>query</i> da consulta, faça algo como:

  User.all.page(params[:page]).per(:page_size)

Para mais informações, visite a página do projeto.

<b>Respondendo outros formatos</b>

Esta API só responde requisiões do tipo JSON. Para alterar ou adicionar um novo formato de resposta, altere os métodos <b>index</b>, <b>show</b>, <b>create</b>, <b>update</b> e <b>destroy</b> da classe localizada em <b>app/controllers/api/v1/base_controller.rb</b>

  respond_to do |format|
    format.json { render :index }
  end

Qualquer requisição de outro formato não configurado, feita a um recurso da API, gerará um erro de formato desconhecido.

=== Sessões de usuário

Além da API Restful, este projeto também conta com um sistema de autenticação baseado em login de usuários. Logo, todos os métodos, tanto da API como de outros controladores herdarão uma ação que força a autenticação do usuário, exceto dois métodos já configurados:

* POST /api/v1/users.json
* GET /

O primeiro não está protegido por autenticação porque é o responsável por permitir a criação de novos usuários dentro da aplicação.

O segundo, está parcialmente protegido. Isto quer dizer que, para usuários logados e não logados, os templates renderizados são diferentes. O template <b>app/views/application/index.html.erb</b> é renderizado quando o usuário não está logado, enquanto o template <b>app/views/application/home.html.erb</b> é renderizado quando o usuário está logado.

Você pode alterar esse comportamento conforme desejar, apenas alterando as classes <b>ApplicationController</b> e <b>BaseController</b>, localizadas em <b>app/controllers</b>.

<b>Rotas</b>

Para logar um usuário na sessáo, utilize a rota:

* POST /sessions/signin.json

E monte a requisição dessa maneira:

  user: {
    email: "user@sample.com",
    password: "pass123"
  }

Para deslogar um usuário da sessão, utilize a rota:
* GET /sessions/signout

<b>Usuário atual da sessão</b>

Em qualquer controlador ou view que herde direta ou indiretamente a classe<b>ApplicationController</b>, você tem a variável de instância <b>@current_user</b>, que contém todas as informações do usuário atual da sessão.

=== Outras observações

* Estamos usando a gem {paperclip}[https://github.com/thoughtbot/paperclip] para adicionar a funcionalidade de upload de arquivos
