
// ui/js/script.js

const menu = document.getElementById('menu');
const tabs = document.querySelectorAll('.tab-btn');
const panes = document.querySelectorAll('.tab-pane');
const playersList = document.getElementById('players-list');
let currentPlayerTarget = null;

// Navegación por pestañas
tabs.forEach(btn => {
    btn.addEventListener('click', () => {
        const tabId = btn.getAttribute('data-tab');
        // Actualizar botones activos
        tabs.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        // Mostrar panel correspondiente
        panes.forEach(pane => pane.classList.remove('active'));
        document.getElementById(`tab-${tabId}`).classList.add('active');
        // Si es la pestaña de jugadores, refrescar lista
        if (tabId === 'player') {
            refreshPlayers();
        }
    });
});

// Enviar acción a Lua
function sendAction(action, data = {}) {
    fetch(`https://SENTEX/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    }).catch(e => console.error('Error sending action', e));
}

// Asignar eventos a los botones estáticos
document.querySelectorAll('.menu-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
        const action = btn.getAttribute('data-action');
        if (action) sendAction(action);
    });
});

// Obtener lista de jugadores desde Lua
function refreshPlayers() {
    fetch('https://SENTEX/getPlayers', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(players => {
        if (!players || players.length === 0) {
            playersList.innerHTML = '<div class="loading">No hay jugadores conectados</div>';
            return;
        }
        let html = '';
        players.forEach(p => {
            html += `
                <div class="player-item">
                    <span class="player-name">${p.name}</span>
                    <div class="player-actions">
                        <button class="player-btn" data-pid="${p.id}" data-action="inventory">🎒 Inv</button>
                        <button class="player-btn" data-pid="${p.id}" data-action="revive">💊 Revivir</button>
                        <button class="player-btn" data-pid="${p.id}" data-action="kill">💀 Matar</button>
                        <button class="player-btn" data-pid="${p.id}" data-action="teleport">📍 TP</button>
                        <button class="player-btn" data-pid="${p.id}" data-action="spawnnpc">👾 NPCs</button>
                        <button class="player-btn" data-pid="${p.id}" data-action="framing">🎭 Framing</button>
                    </div>
                </div>
            `;
        });
        playersList.innerHTML = html;
        // Asignar eventos a los botones dinámicos
        document.querySelectorAll('.player-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                const pid = parseInt(btn.getAttribute('data-pid'));
                const action = btn.getAttribute('data-action');
                sendAction(action, { pid: pid });
            });
        });
    })
    .catch(err => {
        console.error(err);
        playersList.innerHTML = '<div class="loading">Error al cargar jugadores</div>';
    });
}

// Actualizar estado de anticheat
window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.type === 'openMenu') {
        menu.style.display = 'flex';
        // Si la pestaña activa es jugadores, refrescar al abrir
        const activeTab = document.querySelector('.tab-btn.active').getAttribute('data-tab');
        if (activeTab === 'player') refreshPlayers();
    } else if (data.type === 'closeMenu') {
        menu.style.display = 'none';
    } else if (data.type === 'updateACStatus') {
        const acSpan = document.getElementById('ac-status');
        if (data.detected) {
            acSpan.innerHTML = '⚠️ ANTICHEAT DETECTADO';
            acSpan.style.color = '#ff5555';
        } else {
            acSpan.innerHTML = '🛡️ SIN ANTICHEAT';
            acSpan.style.color = '#55ff55';
        }
    } else if (data.type === 'updatePlayers') {
        // Actualizar lista si estamos en la pestaña de jugadores
        const activeTab = document.querySelector('.tab-btn.active').getAttribute('data-tab');
        if (activeTab === 'player') refreshPlayers();
    }
});

// Cerrar con ESC
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        sendAction('closeMenu');
    }
});
