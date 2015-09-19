require 'webrick'
require 'yaml'

class WebDictionary < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    if File.exist?("data.yml")
      dictionary = YAML::load(File.read("data.yml"))
    else
      dictionary = []
    end

    html = "<ul>" + dictionary.map { |entry| "<li>Word: #{entry[:word]} Definition: #{entry[:definition]}" }.join + "</ul>"

    response.status = 200
    response.body = %{
      <html>
        <body>
        <a href="/add">Add Word to Dictionary</a>
        <form method="POST" action="/search"
        <ul>
          <li>Search for a Word:</li>
          <li><input name="search_word" /></li>
        </ul>
        <button type="submit">Search</button>
        </form>
        <hr>
        <p>Dictionary</p>

        <p>#{html}</p>
        </body>
      </html>
    }
  end
end

class AddWord < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)

    response.status = 200
    response.body = %{
      <html>
        <body>
          <form method="POST" action="/save">
          <ul>
            <li>Add Word to Dictionary:</li>
            <li><input name="word" /></li>
            <li>Add Definition:</li>
            <li><input name="definition" />
            <li><button type="submit">Add Word</button></li>
          </form>
          </ul>
        </body>
      </html>
    }
  end
end

class SaveWord < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    # get word and definition from the request
    word = request.query["word"].to_s
    definition = request.query["definition"].to_s

    # but first read the current dictionary from the file (as YAML)
    if File.exist?("data.yml")
      dictionary = YAML::load(File.read("data.yml"))
    else
      dictionary = []
    end
    # New dictionary should have the new word and definition in it
    new_definition = {word: word, definition: definition}
    dictionary << new_definition
    # Writing out the dictionary to yaml
    # File.open("data.yml", "a+") do |file|
    #   file.puts "Word: #{request.query["word"]} Definition: #{request.query["definition"]}"
    # end

    response.status = 302
    response.header["Location"] = "/"
    response.body = %{
      <html>
        <body>
          <p>Saved Word to Dictionary!</p>
        </body>
      </html>
    }
  end
end

class SearchWord < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    if File.exist?("data.yml")
      dictionary = YAML::load(File.read("data.yml"))
    else
      dictionary = []
    end

    search_results = dictionary.select { |entry| entry[:word] == request.query["search"] }
    search_html = "<ul>" + search_results.map { |entry| "<li>#{entry[:word]} #{entry[:definition]}" }.join + "</ul>"

    response.status = 200
    response.body = %{
      <html>
        <body>
        <a href="/">Back to Dictionary</a>
        <p>#{search_html}</p>
        </body>
      </html>
    }
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount "/", WebDictionary
server.mount "/add", AddWord
server.mount "/save", SaveWord
server.mount "/search", SearchWord

trap("INT") { server.stop }

server.start
