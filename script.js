// CONFIGURACIÓN DE SEGURIDAD
const ADMIN_EMAIL = "endersonsoto06@gmail.com";

// Simulamos que el sistema detecta tu sesión 
// (En una web real esto vendría de un Login, aquí lo forzamos para tu prueba)
let userEmail = prompt("Introduce tu correo para verificar identidad:");

if (userEmail === ADMIN_EMAIL) {
    document.getElementById('admin-panel').style.display = 'block';
    console.log("Acceso de administrador concedido.");
} else {
    console.log("Modo visitante activo.");
}

// Función para el botón de subida
function uploadPlugin() {
    // Esto te lleva directo a la carpeta de plugins en tu repo para subir archivos
    // Reemplaza 'Enderson211' y 'Ender' por los nombres reales de tu cuenta y repo
    const repoUrl = "https://github.com/Enderson211/Ender/upload/main/plugins";
    window.location.href = repoUrl;
}

console.log("EnderStudio Mobile-Ready cargado.");
