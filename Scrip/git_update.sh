#!/bin/bash
# Script interactivo para actualizar GitHub

echo "======================================"
echo "   Actualizar carpeta a GitHub"
echo "======================================"
echo ""

# Preguntar el mensaje del commit
read -p "Escribe el mensaje para el commit: " mensaje

# Confirmar antes de continuar
echo ""
echo "Vas a ejecutar:"
echo "git add ."
echo "git commit -m \"$mensaje\""
echo "git push"
echo ""
read -p "¿Deseas continuar? (s/n): " confirmacion

if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
    git add .
    git commit -m "$mensaje"
    git push
    echo ""
    echo " Cambios enviados a GitHub con éxito."
else
    echo ""
    echo " Operación cancelada."
fi


echo "======================================"
echo "   Elaborado por Jafet Arauz  "
echo "======================================"
echo ""
