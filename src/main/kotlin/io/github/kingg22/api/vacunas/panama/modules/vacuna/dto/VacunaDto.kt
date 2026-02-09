package io.github.kingg22.api.vacunas.panama.modules.vacuna.dto

import com.fasterxml.jackson.annotation.JsonProperty
import io.github.kingg22.api.vacunas.panama.modules.fabricante.dto.FabricanteDto
import io.github.kingg22.api.vacunas.panama.modules.vacuna.entity.Vacuna
import io.mcarle.konvert.api.KonvertFrom
import io.mcarle.konvert.api.Mapping
import io.quarkus.runtime.annotations.RegisterForReflection
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.PastOrPresent
import jakarta.validation.constraints.Size
import java.io.Serializable
import java.time.LocalDateTime
import java.time.ZoneOffset.UTC
import java.util.UUID

/** DTO for [io.github.kingg22.api.vacunas.panama.modules.vacuna.entity.Vacuna] */
@RegisterForReflection
@KonvertFrom(Vacuna::class, [Mapping("dosisMaxima", constant = "null")])
@JvmRecord
data class VacunaDto(
    val id: UUID? = null,

    @all:Size(max = 100)
    @all:NotBlank
    val nombre: String,

    @all:JsonProperty(value = "edad_minima_dias")
    val edadMinimaDias: Short? = null,

    @all:JsonProperty(value = "dosis_maxima")
    val dosisMaxima: NumDosisEnum? = null,

    @all:JsonProperty(value = "created_at")
    @all:PastOrPresent
    val createdAt: LocalDateTime = LocalDateTime.now(UTC),

    @all:JsonProperty(value = "updated_at")
    @all:PastOrPresent
    val updatedAt: LocalDateTime? = null,

    val fabricantes: Set<@Valid FabricanteDto> = emptySet(),
) : Serializable {
    companion object
}
