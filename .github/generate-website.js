const fs = require('fs-extra');
const { marked } = require('marked');
const markedAlert = require('marked-alert');
const path = require('path');

fs.ensureDirSync('docs');

const readmeContent = fs.readFileSync('README.md', 'utf8');
const renderer = new marked.Renderer();
const originalBlockquote = renderer.blockquote.bind(renderer);

renderer.blockquote = function(quote) {
    const alertMatch = quote.match(/^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*/i);
    
    if (alertMatch) {
        const alertType = alertMatch[1].toLowerCase();
        const content = quote.replace(/^\[!.*?\]\s*/i, '');
        
        const icons = {
            note: '📘',
            tip: '💡',
            important: '❗',
            warning: '⚠️',
            caution: '🚨'
        };
        
        return `<div class="markdown-alert markdown-alert-${alertType}">
                    <div class="markdown-alert-title">${icons[alertType]} ${alertType.toUpperCase()}</div>
                    ${content}
                </div>`;
    }
    
    return originalBlockquote(quote);
};

// Generate HTML template
const generateHTML = (content) => `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Windows Libraries of libaacs & libbdplus</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/marked/11.1.1/marked.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --bg-primary: #ffffff;
            --bg-secondary: #f8f9fa;
            --text-primary: #1a1a1a;
            --text-secondary: #6c757d;
            --accent: #2563eb;
            --accent-hover: #1d4ed8;
            --border: #e5e7eb;
            --code-bg: #f1f3f5;
            --warning-bg: #fef3c7;
            --warning-border: #fbbf24;
            --success: #10b981;
            --success-hover: #059669;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.7;
            color: var(--text-primary);
            background: var(--bg-primary);
        }

        .container {
            max-width: 860px;
            margin: 0 auto;
            padding: 60px 24px;
        }

        header {
            margin-bottom: 30px;
            padding-bottom: 32px;
            border-bottom: 1px solid var(--border);
        }

        h1 {
            font-size: 2.25rem;
            font-weight: 700;
            letter-spacing: -0.025em;
            margin-bottom: 16px;
            color: var(--text-primary);
        }

        .subtitle {
            font-size: 1.125rem;
            color: var(--text-secondary);
            margin-bottom: 24px;
        }

        .button-group {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 500;
            transition: transform 0.2s, box-shadow 0.2s;
            text-decoration: none;
            border: none;
            cursor: pointer;
            font-size: 1rem;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        .btn-primary {
            background: var(--text-primary);
            color: white;
        }

        .btn-success {
            background: var(--success);
            color: white;
        }

        .btn-success:hover {
            background: var(--success-hover);
        }

        a.btn:hover {
            color: #FFFFFF !important;
            text-decoration: none !important;
        }

        /* Modal styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            animation: fadeIn 0.2s;
        }

        .modal.active {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .modal-content {
            background-color: white;
            padding: 0px 32px 40px 32px;
            border-radius: 12px;
            max-width: 500px;
            width: 90%;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            animation: slideUp 0.3s;
        }

        @keyframes slideUp {
            from {
                transform: translateY(20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .modal-header {
            margin-bottom: 24px;
        }

        .modal-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .modal-subtitle {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        .option-group {
            margin-bottom: 24px;
        }

        .option-label {
            display: block;
            font-weight: 500;
            margin-bottom: 12px;
            color: var(--text-primary);
        }

        .option-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .option-btn {
            padding: 12px 16px;
            border: 2px solid var(--border);
            background: white;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
            font-weight: 500;
            text-align: center;
        }

        .option-btn:hover {
            border-color: var(--accent);
            background: var(--bg-secondary);
        }

        .option-btn.selected {
            border-color: var(--accent);
            background: var(--accent);
            color: white;
        }

        .modal-footer {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 24px;
        }

        .btn-secondary {
            background: var(--bg-secondary);
            color: var(--text-primary);
        }

        .loading {
            text-align: center;
            padding: 40px;
            color: var(--text-secondary);
        }

        .spinner {
            border: 3px solid var(--border);
            border-top: 3px solid var(--accent);
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 16px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        h2 {
            font-size: 1.75rem;
            font-weight: 600;
            margin: 48px 0 20px 0;
            color: var(--text-primary);
        }

        h3 {
            font-size: 1.25rem;
            font-weight: 600;
            margin: 32px 0 16px 0;
            color: var(--text-primary);
        }

        p {
            margin-bottom: 16px;
            color: var(--text-secondary);
        }

        a {
            color: var(--accent);
            text-decoration: none;
            transition: color 0.2s;
        }

        a:hover {
            color: var(--accent-hover);
            text-decoration: underline;
        }

        code {
            background: var(--code-bg);
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.9em;
            font-family: 'Courier New', monospace;
        }

        pre {
            background: var(--code-bg);
            padding: 20px;
            border-radius: 8px;
            overflow-x: auto;
            margin: 20px 0;
            border: 1px solid var(--border);
        }

        pre code {
            background: none;
            padding: 0;
        }

        blockquote {
            border-left: 4px solid var(--warning-border);
            padding: 16px 20px;
            margin: 24px 0;
            background: var(--warning-bg);
            border-radius: 4px;
        }

        blockquote p:last-child {
            margin-bottom: 0;
        }

        .features {
            background: var(--bg-secondary);
            padding: 16px 20px;
            border-radius: 8px;
            margin: 20px 0;
            border: 1px solid var(--border);
        }

        footer {
            margin-top: 80px;
            padding-top: 32px;
            border-top: 1px solid var(--border);
            text-align: center;
            color: var(--text-secondary);
            font-size: 0.875rem;
        }

        .section {
            margin-bottom: 40px;
        }

        ul, ol {
            margin-left: 24px;
            margin-bottom: 16px;
            color: var(--text-secondary);
        }

        li {
            margin-bottom: 8px;
        }

        #content img {
            max-width: 100%;
            height: auto;
        }

        @media (max-width: 768px) {
            .container {
                padding: 40px 20px;
            }

            h1 {
                font-size: 1.75rem;
            }

            h2 {
                font-size: 1.5rem;
            }

            .button-group {
                flex-direction: column;
            }

            .btn {
                width: 100%;
                justify-content: center;
            }

            .option-buttons {
                grid-template-columns: 1fr;
            }
        }
        
        .markdown-alert {
            background-color: #f8f9fa;
            border-left: 4px solid #f0ad4e;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 3px;
        }
        
        .markdown-alert-note {
            border-color: #0088cc;
            background-color: rgba(0, 136, 204, 0.1);
        }
        
        .markdown-alert-tip {
            border-color: var(--secondary-color);
            background-color: rgba(37, 211, 102, 0.1);
        }
        
        .markdown-alert-important {
            border-color: #8e44ad;
            background-color: rgba(142, 68, 173, 0.1);
        }
        
        .markdown-alert-warning {
            border-color: #f0ad4e;
            background-color: rgba(240, 173, 78, 0.1);
        }
        
        .markdown-alert-caution {
            border-color: #ff9800;
            background-color: rgba(255, 152, 0, 0.1);
        }
        
        .markdown-alert p {
            margin: 0;
        }
        
        .markdown-alert-title {
            font-weight: 600;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Windows Libraries of libaacs & libbdplus</h1>
            <p class="subtitle">Prebuilt Windows libraries of libaacs & libbdplus</p>
            <div class="button-group">
                <a href="https://github.com/KnugiHK/libaacs-libbdplus-windows" class="btn btn-primary">
                    <svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor">
                        <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
                    </svg>
                    View On GitHub
                </a>
				<a href="https://github.com/KnugiHK/libaacs-libbdplus-windows/releases/latest" class="btn btn-success">
					<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                        <polyline points="7 10 12 15 17 10"></polyline>
                        <line x1="12" y1="15" x2="12" y2="3"></line>
                    </svg>
                    Download Binary
				</a>
            </div>
        </header>

        <main id="content">
            ${content}
        </main>

        <footer>
            <p>Project maintained by <a href="https://github.com/KnugiHK">KnugiHK</a></p>
            <p>Licensed under GPLv3</p>
            <p><small>Last updated: ${new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</small></p>
        </footer>
    </div>
</body>
</html>
`;


// Remove the first h1 heading
const cleanReadme = readmeContent.replace(/^#\s+.+([\r\n]|$)/m, "");
const htmlContent = marked.use(markedAlert()).parse(cleanReadme, {
  gfm: true,
  breaks: true,
  renderer: new marked.Renderer()
});
const finalHTML = generateHTML(htmlContent);
fs.writeFileSync('docs/index.html', finalHTML);

console.log('✅ Website generated successfully!');
console.log('📁 Output: docs/index.html');