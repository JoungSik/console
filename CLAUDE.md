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
- **Dark Mode**: Always include `dark:` variants for all UI elements (follows browser settings)
  - Background: `bg-white dark:bg-gray-800`, cards: `bg-gray-50 dark:bg-gray-700`
  - Text: `text-gray-900 dark:text-white`, secondary: `text-gray-500 dark:text-gray-400`
  - Borders: `border-gray-200 dark:border-gray-700`, inputs: `border-gray-300 dark:border-gray-600`
  - Hover states: `hover:bg-gray-50 dark:hover:bg-gray-600`
  - Forms: inputs need `bg-white dark:bg-gray-700 text-gray-900 dark:text-white`
  - Status badges: `bg-green-100 dark:bg-green-800 text-green-800 dark:text-green-100`

## Allowed Files
- *.html.erb (views)
- *.css, *.scss (styles)
- *.js (Stimulus controllers)
- *.json.jbuilder (JSON views)

## Process
1. Read CLAUDE.md first
2. Check if request is view-related
3. Inform user if non-view changes needed