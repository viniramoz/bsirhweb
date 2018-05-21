require 'rubygems'
require 'sinatra'
require 'rexml/document' # standard XML parser
require 'sinatra/cookies' # for using cookie
require 'nokogiri'

def parse_user_input(xml)
 array = Array.new
 doc = REXML::Document.new(xml)
 begin
 doc.elements.each('SerioEvent/UserInput/UserInputValues/KeyValueData') { |kv|
 array << {
 :key => kv.elements['Key'].text,
 :value => kv.elements['Value'].text
 }
 }
 rescue
 puts "PARSE ERROR OCCURRED."
 end
 array
end


def save_session(params)
 # Inherit existing cookies to next session.
 cookies.each do |k, v|
 cookies[k] = v
 end
 
 return unless params[:xml]
 # novos valores
 keyvalues = parse_user_input(params[:xml].to_s) # Event message is always stored
 # as value of "xml".
 keyvalues.each { |kv| case kv[:key]
 
 when "func_nome"
 cookies[:func_nome] = kv[:value].to_str #set cookie
 end
  
 }
end

def salvar_func()
	value_not_enough = false
	unless cookies[:func_nome]
 	 puts "NO DATA :func_nome"
 	 value_not_enough = true
 	end

   doc_nome = cookies[:func_nome].to_str
   nome = doc_nome

   Dir.mkdir("C:\\bsirh") unless Dir.exist?("C:\\bsirh\\")
   File.open("C:\\bsirh\\bd_nomes.txt", 'a') { |file| file.write("#{nome};") }
end

#-------------------------------------------------
# Routes
#-------------------------------------------------

# INICIO ------------
post "/init" do
	system('cls')
	system('clear')
	@param = {
	:objtitle => "Inserir Documentos para:",
	:newFunc => "Novo Funcionário",
	:oldFunc => "Funcionário já Cadastrado",
}
 
content_type :xml
erb :inicio 
end

get "/init" do
  content_type :xml
  erb :inicio
end

# NOVO FUNCIONÁRIO ------------
post "/NewFunc" do
content_type :xml
erb :cadFunc 
end

get "/NewFunc" do
		@param = {
		 :submit => "./lista_docs/*",
		 :back => "./NewFunc",
		 :objtitle => "Digite o Nome",
		 :id => "func_nome",
		 :min => "10",
		 :field => "UpperCase",
		 :field2 => "LowerCase",
		 :max => "128"
 }
  content_type :xml
  erb :cadFunc
end

# FUNCIONÁRIO JÁ EXISTENTE -
get "/OldFunc" do
	        text = 'C:\\bsirh\\bd_nomes.txt'
            f = File.open(text , "r")
            conteudo = f.read
            quant = conteudo.split(";").size

            itens =""

            for i in 0..quant
            nomeExibido = conteudo.split(";")[i].to_s
            nomeExibido.gsub!('+', ' ')
             # itens += '<Item selected="true" value="'+conteudo.split(";")[i].to_s+'"><Label>'+conteudo.split(";")[i].to_s+'</Label></Item>'
            itens += ' <LinkItem href="./lista_docs/'+conteudo.split(";")[i].to_s+'"><Label >'+nomeExibido+'</Label></LinkItem>'
            end 
            f.close

		@param = {
			 :item => itens   			 
 		}
 			 content_type :xml
  		 erb :list_func
end

post "/OldFunc" do
	content_type :xml
	erb :inicio 
end

# LISTA DOCUMENTOS ------------
post "/lista_docs/*" do
save_session(params)
salvar_func()

  content_type :xml
  erb :list_doc
end

get "/lista_docs/*" do
  cookies[:func_nome] = request.fullpath.split("/lista_docs/")[1]

@param = {
		 :submit => "./escanear",
		 :back => "./lista_docs/*",
		 :objtitle => "Documento para Armazenagem",
 }

  content_type :xml
  erb :list_doc
end

#-------------------------------------------------
# Routes - Documentos
#-------------------------------------------------

#RG, CPF, Titulo de Eleitor
get "/documentoNumero/*" do #FAZER ROTA PARA pegar numero
  nomedocumento = request.fullpath.split("/documentoNumero/")[1]
  nome = cookies[:func_nome].to_str
  nome.gsub!('+', ' ')
  Dir.mkdir("C:\\Users\\ramos\\Google Drive\\BSI Brother\\" + nome) unless Dir.exist?("C:\\Users\\ramos\\Google Drive\\BSI Brother\\"+nome) 

@param = {
  :server => "NOTE-DEV02",
  :dir => "Users\\ramos\\Google Drive\\BSI Brother\\" + nome,
  :user => "scan\\ramos",
  :pass => "sc@n1234",
  :filename => nomedocumento + " " + nome
 }
  content_type :xml
  erb :scannerDoc
end

# OUTROS DOCUMENTOS
get "/documento/*" do
  nomedocumento = request.fullpath.split("/documento/")[1]

  nome = cookies[:func_nome].to_str
  nome.gsub!('+', ' ')
  Dir.mkdir("C:\\Users\\ramos\\Google Drive\\BSI Brother\\" + nome) unless Dir.exist?("C:\\Users\\ramos\\Google Drive\\BSI Brother\\"+nome)

@param = {
  :server => "172.20.10.3",
  :dir => "Users\\ramos\\Google Drive\\BSI Brother\\" + nome,
  :user => "scan\\ramos",
  :pass => "sc@n1234",
  :filename => nomedocumento +" " +nome
 }
  content_type :xml
  erb :scannerDoc
end