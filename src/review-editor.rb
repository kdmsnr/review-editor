require 'jrubyfx'
if JRubyFX::Application.in_jar?
  fxml_root nil, "review-editor.jar"
else
  fxml_root File.dirname(__FILE__)
end

class ReviewEditorApp < JRubyFX::Application
  def start(stage)

    with(stage, title: "Re:VIEW Editor", width: 600, height: 600) do
      fxml ReviewEditorController
      show
    end
  end
end

class ReviewEditorController
  include JRubyFX::Controller
  fxml "review-editor.fxml"

  def compile
    @error.setVisible(false)
    compiled = $review_editor.compile(@input.getText)
    @output.getEngine.loadContent(compiled)
  rescue => e
    @error.setVisible(true)
    # @error.setText(e.to_s)
    @error.setText($stderr.read)
  end
end

class MyStdError
  def initialize
    @err = ''
  end

  def write
  end

  def puts(str)
    @err = str
  end

  def read
    @err
  end
end

$stderr = MyStdError.new

$LOAD_PATH << "review/lib"
require 'review'
class ReviewEditor
  include ReVIEW

  def initialize
    @builder = HTMLBuilder.new
    @book = Book::Base.new(".")
    @chapter = Book::Chapter.new(@book, 1, '-', nil, StringIO.new)
    @compiler = Compiler.new(@builder)
    @builder.bind(@compiler, @chapter, Location.new(nil, nil))
    I18n.setup("ja")
  end

  def compile(text)
    "" if text.empty?

    @chapter.content = text
    matched = @compiler.compile(@chapter).match(/<body>\n(.+)<\/body>/m)
    if matched && matched.size > 1
      matched[1]
    else
      ""
    end
  end
end

$review_editor = ReviewEditor.new

ReviewEditorApp.launch
