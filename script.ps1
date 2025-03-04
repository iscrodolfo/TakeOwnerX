$folderPath = "C:\CarpetaProtegida"

# Quitar la herencia de permisos
icacls $folderPath /inheritance:r

# Denegar eliminación y control total a todos los usuarios (incluyendo Administradores)
icacls $folderPath /deny Everyone:(F)
icacls $folderPath /deny Administrators:(F)
icacls $folderPath /deny Users:(F)

# Dar acceso total solo a SYSTEM
icacls $folderPath /grant SYSTEM:(F)

Write-Host "🚫 La carpeta $folderPath está protegida contra eliminación."
