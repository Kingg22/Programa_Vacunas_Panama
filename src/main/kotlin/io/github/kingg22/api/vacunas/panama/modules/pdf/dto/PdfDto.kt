package io.github.kingg22.api.vacunas.panama.modules.pdf.dto

import io.github.kingg22.api.vacunas.panama.modules.vacuna.dto.DosisDto
import io.quarkus.runtime.annotations.RegisterForReflection
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotEmpty
import jakarta.validation.constraints.PastOrPresent
import java.io.Serializable
import java.time.LocalDate
import java.util.UUID

/** DTO for generate PDF with basic information  */
@RegisterForReflection
@JvmRecord
data class PdfDto(
    @all:NotBlank
    val nombres: String,

    @all:NotBlank
    val apellidos: String,

    @all:NotBlank
    val identificacion: String,

    @all:PastOrPresent
    val fechaNacimiento: LocalDate? = null,

    val id: UUID? = null,
    // Extraer id fecha_aplicacion, numero_dosis, vacuna.nombre, sede.nombre, doctor.nombre,
    // doctor.idoneidad, lote
    // De esos datos si es null colocar 'Desconocido'
    @all:NotEmpty
    val dosis: List<@Valid DosisDto> = emptyList(),
) : Serializable
