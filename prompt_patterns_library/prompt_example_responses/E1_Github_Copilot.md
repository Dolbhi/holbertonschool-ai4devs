### 1. Commented Rust example

This is a standalone native app using `eframe` (which re-exports `egui`). Add this dependency:
```toml
[dependencies]
eframe = "0.32"
```
Then put the following in `src/main.rs`:

```rust
use eframe::egui;
/// Application state for the word-button editor.
struct WordApp {
    words: Vec<String>,
    edit_mode: bool,
    output_text: String,
}
impl Default for WordApp {
    fn default() -> Self {
        Self {
            words: vec![
                "Hello".to_owned(),
                "World".to_owned(),
                "Rust".to_owned(),
            ],
            edit_mode: false,
            output_text: String::new(),
        }
    }
}
impl eframe::App for WordApp {
    fn update(
        &mut self,
        ctx: &egui::Context,
        _frame: &mut eframe::Frame,
    ) {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.heading("Word list");
            ui.separator();
            // Toggle the list between buttons and editable text fields.
            ui.checkbox(&mut self.edit_mode, "Edit words");
            // Keep the word list scrollable and wrap its items to fit the window.
            {
                let editing = self.edit_mode;
                let words = &mut self.words;
                let output = &mut self.output_text;
                egui::ScrollArea::vertical()
                    .max_height(180.0)
                    .show(ui, |ui| {
                        ui.horizontal_wrapped(|ui| {
                            for (index, word) in words.iter_mut().enumerate() {
                                // Give each generated widget a distinct, stable ID.
                                ui.push_id(("word", index), |ui| {
                                    if editing {
                                        // Editing changes the word in the list directly.
                                        ui.add(
                                            egui::TextEdit::singleline(word)
                                                .desired_width(130.0)
                                                .hint_text("Enter a word"),
                                        );
                                    } else if ui.button(word.as_str()).clicked() {
                                        // Append the selected word, separating it from
                                        // existing text unless that text already ends
                                        // with whitespace.
                                        let selected_word = word.trim();
                                        if !selected_word.is_empty() {
                                            if output
                                                .chars()
                                                .last()
                                                .is_some_and(|ch| !ch.is_whitespace())
                                            {
                                                output.push(' ');
                                            }
                                            output.push_str(selected_word);
                                        }
                                    }
                                });
                            }
                        });
                    });
            }
            ui.add_space(8.0);
            ui.label("Selected words:");
           // The text remains editable, so users can also adjust the result manually.
            ui.add(
                egui::TextEdit::multiline(&mut self.output_text)
                    .desired_rows(4)
                    .desired_width(f32::INFINITY)
                    .hint_text("Click a word above to add it here..."),
            );
            ui.horizontal(|ui| {
               // Add a new item and switch to edit mode so it can be renamed immediately.
                if ui.button("+ Add word").clicked() {
                    self.words.push("New word".to_owned());
                    self.edit_mode = true;
                }
                if ui.button("Clear output").clicked() {
                    self.output_text.clear();
                }
            });
        });
    }
}
fn main() -> eframe::Result<()> {
    eframe::run_native(
        "Word Button Demo",
        eframe::NativeOptions::default(),
        Box::new(|_creation_context| Ok(Box::new(WordApp::default()))),
    )
}
```

### 2. Functions and APIs

- **`update`** — `eframe` calls this to draw the interface and respond to input. The app’s fields hold the state between frames.
- **`CentralPanel::show`** — Creates the main panel and provides the `ui` used to add controls.
- **`ui.checkbox`** — Binds a checkbox to `edit_mode`; that Boolean determines whether list entries render as buttons or text fields.
- **`ScrollArea::show`** — Makes the list scrollable if it grows beyond the available height.
- **`horizontal_wrapped`** — Arranges items horizontally and wraps them onto another line when the window is too narrow.
- **`iter_mut().enumerate()`** — Iterates over the words with mutable access, allowing each text field to edit its word in place.
- **`push_id`** — Gives each generated widget a separate ID scope, which helps egui track widgets created in a loop.
- **`TextEdit::singleline`** — Creates an editable field for one word. **`TextEdit::multiline`** creates the output box.
- **`button(...).clicked()`** — Checks whether the button was clicked this frame. If so, the selected word is appended to the output.
- **`run_native`** — Starts the native desktop window and creates the initial `WordApp`.

The UI is built with egui’s immediate-mode approach: it redraws from the current app state, without a separate UI tree to keep synchronized.

### 3. Alternative implementations

- **Embed the controls in an existing app:** Keep the `WordApp` state and the UI-building code, but call it from your existing `eframe::App::update` instead of defining a separate application.
- **Use a grid or vertical list:** Replace `horizontal_wrapped` with `egui::Grid` or a vertical layout if you prefer aligned columns or one item per row.
- **Add item management:** Provide remove, reorder, or drag-and-drop controls alongside each word if users need to manage the list—not just add and edit entries.
- **Virtualize very large lists:** For a list with thousands of words, render only the visible rows using a virtualized-list approach to reduce per-frame UI work

###