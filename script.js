/**
 * ENDERSTUDIO - SISTEMA DE CONTROL DE INTERFAZ
 * Este script gestiona la interactividad de la web de plugins.
 */

// 1. Mensaje de bienvenida profesional en consola
console.log("%c ENDERSTUDIO 4.0 - SISTEMA CARGADO ", "background: #001a2c; color: #00d9ff; font-size: 20px; font-weight: bold;");
console.log("%c Info: Inicializando módulos de descarga...", "color: #e1f5fe;");

// 2. Función para registrar clics en los botones (Log de auditoría)
const downloadButtons = document.querySelectorAll('.download-btn');

downloadButtons.forEach(button => {
    button.addEventListener('click', function(e) {
        const fileName = this.getAttribute('href');
        console.log(`%c [ACCESO]: Iniciando descarga de: ${fileName}`, "color: #00ff00; font-weight: bold;");
        
        // Efecto visual simple al hacer clic
        this.style.transform = "scale(0.95)";
        setTimeout(() => {
            this.style.transform = "scale(1)";
        }, 100);
    });
});

// 3. Simulación de "Carga de Datos" en la UI
window.onload = function() {
    const statusText = document.querySelector('.status-bar');
    if(statusText) {
        statusText.innerHTML = '<span class="dot"></span> ESCANEANDO REPOSITORIO...';
        
        setTimeout(() => {
            statusText.innerHTML = '<span class="dot" style="background-color: #00d9ff;"></span> SISTEMA OPERATIVO';
            statusText.style.color = "#00d9ff";
        }, 2000);
    }
};

// 4. Protección básica contra copia de consola (Opcional)
document.addEventListener('contextmenu', function(e) {
    // Si quieres evitar que copien fácil, descomenta la línea de abajo
    // e.preventDefault(); 
});
