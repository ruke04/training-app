
// Use relative URL - nginx proxies /api/* to backend
const API_URL = '/api'

let token = null
let currentUsername = null
let pendingModalAction = null

// Check for logout parameter from protected site
if (window.location.search.includes('logout=true')) {
    try {
        localStorage.removeItem('token')
    } catch (_) {}
    // Clean up URL (remove query string)
    window.history.replaceState({}, document.title, window.location.pathname)
}

try {
    const saved = localStorage.getItem('token')
    if (saved) {
        token = saved
        // Auto-fetch profile on page load if token exists
        fetchMe()
    }
} catch (_) {}

function showConfirmModal(title, message, onConfirm) {
    document.getElementById('modalTitle').textContent = title
    document.getElementById('modalMessage').textContent = message
    pendingModalAction = onConfirm
    document.getElementById('confirmModal').classList.add('show')
}

function closeModal() {
    document.getElementById('confirmModal').classList.remove('show')
    pendingModalAction = null
}

function confirmModalAction() {
    if (pendingModalAction) {
        pendingModalAction()
    }
    closeModal()
}

// Close modal when clicking outside
document.addEventListener('DOMContentLoaded', function() {
    const modal = document.getElementById('confirmModal')
    if (modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeModal()
            }
        })
    }
})

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
    const res = await fetch(`${API_URL}/register`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({username, password})
    })
    if (res.ok) {
        const data = await res.json()
        // Don't automatically log in - just show success message
        document.getElementById('register_result').innerText = 'Registration successful! Please login to continue.'
        document.getElementById('register_result').style.color = 'var(--accent-2)'
        // Clear the registration form
        document.getElementById('reg_username').value = ''
        document.getElementById('reg_password').value = ''
    } else {
        const err = await res.json().catch(() => ({}))
        document.getElementById('register_result').innerText = 'Registration failed' + (err.detail ? `: ${err.detail}` : '')
        document.getElementById('register_result').style.color = 'var(--danger)'
    }
}

async function login() {
    const username = document.getElementById('username').value
    const password = document.getElementById('password').value
    const res = await fetch(`${API_URL}/login`, {
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
    const res = await fetch(`${API_URL}/me`, {
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
    const url = `${API_URL}/protected?token=${encodeURIComponent(token)}`
    window.location.href = url
}

async function listUsers() {
    console.log('listUsers called, token exists:', !!token)
    if (!token) {
        showNotification('You are not logged in.', 'error')
        return
    }
    
    try {
        console.log('Fetching users with token:', token.substring(0, 20) + '...')
        const res = await fetch(`${API_URL}/users`, {
            method: 'GET',
            headers: { 
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        })
        console.log('Users response status:', res.status)
        
        if (res.ok) {
            const data = await res.json()
            const usersList = document.getElementById('users_list')
            if (data.users && data.users.length > 0) {
                let html = '<div style="background: #0b1020; border: 1px solid var(--border); border-radius: 10px; padding: 12px; max-height: 300px; overflow-y: auto;"><table style="width: 100%; border-collapse: collapse;"><tr style="border-bottom: 1px solid var(--border);"><th style="text-align: left; padding: 8px;">ID</th><th style="text-align: left; padding: 8px;">Username</th><th style="text-align: left; padding: 8px;">Created</th></tr>'
                data.users.forEach(user => {
                    const date = user.created_at ? new Date(user.created_at).toLocaleString() : 'N/A'
                    html += `<tr style="border-bottom: 1px solid var(--border);"><td style="padding: 8px;">${user.id}</td><td style="padding: 8px;">${user.username}</td><td style="padding: 8px; color: var(--muted); font-size: 13px;">${date}</td></tr>`
                })
                html += '</table></div>'
                usersList.innerHTML = html
            } else {
                usersList.innerHTML = '<p style="color: var(--muted);">No users found.</p>'
            }
        } else {
            const err = await res.json().catch(() => ({}))
            const errorMsg = err.detail || `HTTP ${res.status}: ${res.statusText}` || 'Unknown error'
            console.error('Failed to fetch users:', errorMsg, res)
            showNotification('Failed to fetch users: ' + errorMsg, 'error')
            document.getElementById('users_list').innerHTML = `<p style="color: var(--danger);">Error: ${errorMsg}</p>`
        }
    } catch (error) {
        console.error('Error fetching users:', error)
        showNotification('Error fetching users: ' + error.message, 'error')
        document.getElementById('users_list').innerHTML = `<p style="color: var(--danger);">Error: ${error.message}</p>`
    }
}

async function deleteUser() {
    console.log('deleteUser called, token exists:', !!token)
    if (!token) {
        showNotification('You are not logged in.', 'error')
        return
    }
    
    const username = document.getElementById('delete_username').value.trim()
    console.log('Username to delete:', username)
    if (!username) {
        showNotification('Please enter a username to delete.', 'error')
        return
    }
    
    showConfirmModal(
        'Delete User',
        `Are you sure you want to delete user "${username}"? This action cannot be undone.`,
        async () => {
            try {
                await performDeleteUser(username)
            } catch (error) {
                console.error('Error in delete user:', error)
            }
        }
    )
}

async function performDeleteUser(username) {
    if (!token) {
        showNotification('You are not logged in.', 'error')
        return
    }
    
    try {
        console.log('Deleting user:', username)
        const res = await fetch(`${API_URL}/users/${encodeURIComponent(username)}`, {
            method: 'DELETE',
            headers: { 
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        })
        console.log('Delete user response status:', res.status)
        
        if (res.ok) {
            const data = await res.json()
            showNotification(data.message || 'User deleted successfully', 'success')
            document.getElementById('delete_username').value = ''
            // Refresh users list if it was shown
            if (document.getElementById('users_list').innerHTML) {
                listUsers()
            }
        } else {
            const err = await res.json().catch(() => ({}))
            const errorMsg = err.detail || `HTTP ${res.status}: ${res.statusText}` || 'Unknown error'
            console.error('Failed to delete user:', errorMsg, res)
            showNotification('Failed to delete user: ' + errorMsg, 'error')
        }
    } catch (error) {
        console.error('Error deleting user:', error)
        showNotification('Error deleting user: ' + error.message, 'error')
    }
}

async function deleteAccount() {
    console.log('deleteAccount called, token exists:', !!token)
    if (!token) {
        showNotification('You are not logged in.', 'error')
        return
    }
    
    showConfirmModal(
        'Delete My Account',
        'Are you sure you want to delete your account? This action cannot be undone.',
        async () => {
            try {
                await performDeleteAccount()
            } catch (error) {
                console.error('Error in delete account:', error)
            }
        }
    )
}

async function performDeleteAccount() {
    if (!token) {
        showNotification('You are not logged in.', 'error')
        return
    }
    
    try {
        console.log('Deleting my account')
        const res = await fetch(`${API_URL}/me`, {
            method: 'DELETE',
            headers: { 
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        })
        console.log('Delete account response status:', res.status)
        
        if (res.ok) {
            const data = await res.json()
            showNotification(data.message || 'Account deleted successfully', 'success')
            // Clear token and logout
            token = null
            try {
                localStorage.removeItem('token')
            } catch (_) {}
            updateProfileDisplay(null)
            document.getElementById('me').innerText = ''
            document.getElementById('result').innerText = ''
            document.getElementById('register_result').innerText = ''
            
            // Clear cookie via logout
            const iframe = document.createElement('iframe')
            iframe.style.display = 'none'
            iframe.style.width = '0'
            iframe.style.height = '0'
            iframe.src = `${API_URL}/logout`
            document.body.appendChild(iframe)
            setTimeout(() => {
                if (iframe.parentNode) {
                    iframe.parentNode.removeChild(iframe)
                }
            }, 500)
        } else {
            const err = await res.json().catch(() => ({}))
            const errorMsg = err.detail || `HTTP ${res.status}: ${res.statusText}` || 'Unknown error'
            console.error('Failed to delete account:', errorMsg, res)
            showNotification('Failed to delete account: ' + errorMsg, 'error')
        }
    } catch (error) {
        console.error('Error deleting account:', error)
        showNotification('Error deleting account: ' + error.message, 'error')
    }
}

function logout() {
    token = null
    try {
        localStorage.removeItem('token')
    } catch (_) {}
    // Clear the auth_token cookie by loading logout endpoint in hidden iframe
    // This ensures the cookie is cleared in the browser's context for localhost:8000
    const iframe = document.createElement('iframe')
    iframe.style.display = 'none'
    iframe.style.width = '0'
    iframe.style.height = '0'
    iframe.src = `${API_URL}/logout`
    document.body.appendChild(iframe)
    
    // Remove iframe after it loads
    iframe.onload = function() {
        setTimeout(() => {
            if (iframe.parentNode) {
                iframe.parentNode.removeChild(iframe)
            }
        }, 500)
    }
    
    showNotification('Logged out successfully', 'success')
}

// Expose for inline onclick handlers
window.register = register
window.login = login
window.fetchMe = fetchMe
window.openProtected = openProtected
window.logout = logout
window.deleteAccount = deleteAccount
window.listUsers = listUsers
window.deleteUser = deleteUser
window.closeModal = closeModal
window.confirmModalAction = confirmModalAction
