# Claude Rules

## Core
- Answer in Korean
- Only edit view files
- No controller/model/service changes

## Project Structure
```
app/views/        # ERB templates
app/assets/       # CSS/JS assets
app/javascript/   # Stimulus controllers
```

## Tech Stack
- Rails 8.0.3 with ERB templates
- **Tailwind CSS** (tailwindcss-rails) - Use utility classes
- Stimulus JS (stimulus-rails)
- Turbo (turbo-rails)
- Importmap (importmap-rails)
- Lucide icons (lucide-rails)
- JBuilder for JSON

## Styling Guidelines
- Use Tailwind utility classes in ERB
- Custom CSS in app/assets/stylesheets/
- Tailwind config: app/assets/tailwind/application.css

## Allowed Files
- *.html.erb (views)
- *.css, *.scss (styles)
- *.js (Stimulus controllers)
- *.json.jbuilder (JSON views)

## Process
1. Read CLAUDE.md first
2. Check if request is view-related
3. Inform user if non-view changes needed