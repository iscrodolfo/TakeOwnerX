Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configurar colores y estilos
$primaryColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$buttonColor = [System.Drawing.Color]::FromArgb(28, 151, 234)
$textColor = [System.Drawing.Color]::White
$accentColor = [System.Drawing.Color]::FromArgb(0, 122, 204)

# Crear la ventana principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "TakeOwnerX"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.BackColor = $primaryColor
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Titulo centrado y más grande
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "TakeOwnerX"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 32, [System.Drawing.FontStyle]::Bold)  # Aumenté el tamaño a 32
$titleLabel.Size = New-Object System.Drawing.Size(460, 60)  # Ajusté el tamaño para adaptarse al nuevo texto
$titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$titleLabel.ForeColor = $accentColor
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($titleLabel)

# Crear botones con diseño moderno
function Create-Button($text, $x, $y) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size(220, 40)
    $btn.BackColor = $buttonColor
    $btn.ForeColor = $textColor
    $btn.FlatStyle = "Flat"
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    return $btn
}

$btnFile = Create-Button "Seleccionar Archivo" 20 80
$btnFolder = Create-Button "Seleccionar Carpeta" 250 80
$btnInfo = Create-Button "Informacion del Desarrollador" 135 140
$form.Controls.Add($btnFile)
$form.Controls.Add($btnFolder)
$form.Controls.Add($btnInfo)

# Etiqueta de estado
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Estado: Esperando seleccion..."
$lblStatus.Location = New-Object System.Drawing.Point(20, 200)
$lblStatus.Size = New-Object System.Drawing.Size(460, 50)
$lblStatus.ForeColor = $textColor
$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$form.Controls.Add($lblStatus)

# Funcion para mostrar la ventana de informacion del desarrollador
function Show-InfoWindow {
    $infoForm = New-Object System.Windows.Forms.Form
    $infoForm.Text = "Informacion del Desarrollador"
    $infoForm.Size = New-Object System.Drawing.Size(500, 300)
    $infoForm.StartPosition = "CenterScreen"
    $infoForm.BackColor = $primaryColor
    $infoForm.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $infoForm.FormBorderStyle = "FixedDialog"
    $infoForm.MaximizeBox = $false

    $lblDeveloper = New-Object System.Windows.Forms.Label
    $lblDeveloper.Text = "Desarrollador: iscrodolfoalvarez"
    $lblDeveloper.Location = New-Object System.Drawing.Point(20, 20)
    $lblDeveloper.Size = New-Object System.Drawing.Size(460, 30)
    $lblDeveloper.ForeColor = $accentColor
    $infoForm.Controls.Add($lblDeveloper)

    function Create-LinkLabel($text, $url, $x, $y) {
        $link = New-Object System.Windows.Forms.LinkLabel
        $link.Text = $text
        $link.Location = New-Object System.Drawing.Point($x, $y)
        $link.Size = New-Object System.Drawing.Size(460, 30)
        $link.LinkBehavior = [System.Windows.Forms.LinkBehavior]::AlwaysUnderline
        $link.ForeColor = $accentColor
        $link.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Underline)
        $link.Add_LinkClicked({
            Start-Process $url
        })
        return $link
    }

    $infoForm.Controls.Add((Create-LinkLabel "Canal de YouTube" "https://www.youtube.com/@iscrodolfoalvarez" 20 60))
    $infoForm.Controls.Add((Create-LinkLabel "Apoyo en PayPal" "https://www.paypal.com/paypalme/rodolfoalvarez90" 20 100))
    $infoForm.Controls.Add((Create-LinkLabel "Perfil de GitHub" "https://github.com/iscrodolfo" 20 140))

    $btnClose = Create-Button "Cerrar" 135 200
    $btnClose.Add_Click({ $infoForm.Close() })
    $infoForm.Controls.Add($btnClose)

    $infoForm.Topmost = $true
    $infoForm.ShowDialog()
}

# Funcion para confirmar eliminacion
function Confirm-Delete {
    param ($Path)
    $dialogResult = [System.Windows.Forms.MessageBox]::Show("Quieres eliminar `"$Path`"?", "Confirmar Eliminacion", "YesNo", "Question")
    return $dialogResult -eq "Yes"
}

# Funcion para tomar propiedad y eliminar restricciones
function Take-Ownership {
    param ($Path)
    try {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c takeown /f `"$Path`" /r /d Y" -Verb RunAs -WindowStyle Hidden
        Start-Sleep -Seconds 1
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c icacls `"$Path`" /grant Administrators:F /t /c /l /q" -Verb RunAs -WindowStyle Hidden
        Start-Sleep -Seconds 1
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c icacls `"$Path`" /reset /T /C /L /Q" -Verb RunAs -WindowStyle Hidden
        Start-Sleep -Seconds 1

        if (Confirm-Delete -Path $Path) {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            $lblStatus.Text = "Estado: Propiedad adquirida y eliminado."
        } else {
            $lblStatus.Text = "Estado: Propiedad adquirida, archivo/carpeta conservado."
        }
    } catch {
        $lblStatus.Text = "Error al tomar propiedad o modificar permisos."
    }
}

# Evento para seleccionar archivo
$btnFile.Add_Click({
    $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
    if ($FileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Take-Ownership -Path $FileDialog.FileName
    }
})

# Evento para seleccionar carpeta
$btnFolder.Add_Click({
    $FolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($FolderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Take-Ownership -Path $FolderDialog.SelectedPath
    }
})

# Evento para abrir la ventana de informacion del desarrollador
$btnInfo.Add_Click({
    Show-InfoWindow
})

# Ejecutar la interfaz
$form.Topmost = $true
$form.ShowDialog()
