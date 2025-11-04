
let token = null
let currentUsername = null

try {
    const saved = localStorage.getItem('token')
    if (saved) {
        token = saved
        // Auto-fetch profile on page load if token exists
        fetchMe()
    }
} catch (_) {}

function updateProfileDisplay(username) {
    const profileDisplay = document.getElementById('profile_display')
    const profileUsername = document.getElementById('profile_username')
    const profileStatus = document.getElementById('profile_status')
    
    if (username) {
        currentUsername = username
        profileUsername.textContent = `👤 ${username}`
        profileStatus.textContent = 'Logged in'
        profileStatus.style.color = 'var(--accent-2)'
        profileDisplay.classList.add('show')
    } else {
        currentUsername = null
        profileUsername.textContent = '-'
        profileStatus.textContent = 'Not logged in'
        profileStatus.style.color = 'var(--muted)'
        profileDisplay.classList.remove('show')
    }
}

async function register() {
    const username = document.getElementById('reg_username').value
    const password = document.getElementById('reg_password').value
    const res = await fetch('http://localhost:8000/register', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({username, password})
    })
    if (res.ok) {
        const data = await res.json()
        token = data.token
        try { localStorage.setItem('token', token) } catch (_) {}
        document.getElementById('register_result').innerText = 'Registration successful'
        // Auto-fetch profile after registration
        fetchMe()
    } else {
        const err = await res.json().catch(() => ({}))
        document.getElementById('register_result').innerText = 'Registration failed' + (err.detail ? `: ${err.detail}` : '')
    }
}

async function login() {
    const username = document.getElementById('username').value
    const password = document.getElementById('password').value
    const res = await fetch('http://localhost:8000/login', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({username, password})
    })
    if (res.ok) {
        const data = await res.json()
        token = data.token
        try { localStorage.setItem('token', token) } catch (_) {}
        document.getElementById('result').innerText = 'Login successful'
        // Auto-fetch profile after login
        fetchMe()
    } else {
        document.getElementById('result').innerText = 'Login failed'
    }
}

async function fetchMe() {
    if (!token) {
        updateProfileDisplay(null)
        document.getElementById('me').innerText = 'Not logged in'
        return
    }
    const res = await fetch('http://localhost:8000/me', {
        headers: { 'Authorization': `Bearer ${token}` }
    })
    if (res.ok) {
        const data = await res.json()
        updateProfileDisplay(data.username)
        document.getElementById('me').innerText = JSON.stringify(data, null, 2)
    } else {
        updateProfileDisplay(null)
        document.getElementById('me').innerText = 'Not authorized'
    }
}

function showNotification(message, type = 'error') {
    const el = document.getElementById('notification')
    el.textContent = message
    el.className = `notification ${type} show`
    // Allow manual dismiss on click
    el.onclick = () => {
        el.classList.remove('show')
        setTimeout(() => { el.textContent = '' }, 350)
    }
    // Auto dismiss
    setTimeout(() => {
        el.classList.remove('show')
        setTimeout(() => { el.textContent = '' }, 350)
    }, 3000)
}

function openProtected() {
    if (!token) {
        showNotification('You are not logged in. Please login first.', 'error')
        return
    }
    const url = `http://localhost:8000/protected?token=${encodeURIComponent(token)}`
    window.location.href = url
}

function logout() {
    token = null
    try {
        localStorage.removeItem('token')
    } catch (_) {}
    document.getElementById('result').innerText = ''
    document.getElementById('register_result').innerText = ''
    document.getElementById('me').innerText = ''
    updateProfileDisplay(null)
    showNotification('Logged out successfully', 'success')
}

// Expose for inline onclick handlers
window.register = register
window.login = login
window.fetchMe = fetchMe
window.openProtected = openProtected
window.logout = logout
