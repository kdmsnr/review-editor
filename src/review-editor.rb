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

  def key(e)
    if e.isControlDown
      case e.getCode.getName
      when "F"
        @input.fireEvent(KeyEvent.new(KeyEvent::KEY_PRESSED, "", "",
            KeyCode::RIGHT, false, false, false, false))
        e.consume
      when "B"
        @input.fireEvent(KeyEvent.new(KeyEvent::KEY_PRESSED, "", "",
            KeyCode::LEFT, false, false, false, false))
        e.consume
      when "N"
        @input.fireEvent(KeyEvent.new(KeyEvent::KEY_PRESSED, "", "",
            KeyCode::DOWN, false, false, false, false))
        e.consume
      when "P"
        @input.fireEvent(KeyEvent.new(KeyEvent::KEY_PRESSED, "", "",
            KeyCode::UP, false, false, false, false))
        e.consume
      when "E"
        @input.fireEvent(KeyEvent.new(KeyEvent::KEY_PRESSED, "", "",
            KeyCode::END, false, false, false, false))
        e.consume
      when "A"
        @input.fireEvent(KeyEvent.new(KeyEvent::KEY_PRESSED, "", "",
            KeyCode::HOME, false, false, false, false))
        e.consume
      when "K"
        @input.fireEvent(KeyEvent.new(KeyEvent::KEY_PRESSED, "", "",
            KeyCode::END, false, false, false, false))
        @input.fireEvent(KeyEvent.new(KeyEvent::KEY_RELEASED, "", "",
            KeyCode::END, false, false, false, false))
        @input.copy
        @input.fireEvent(KeyEvent.new(KeyEvent::KEY_PRESSED, "", "",
            KeyCode::DELETE, false, false, false, false))
        e.consume
      when "Y"
        @input.paste
        e.consume
      end
    elsif e.isAltDown
      case e.getCode.getName
      when "W"
        @input.copy
        e.consume
      end
    end
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
