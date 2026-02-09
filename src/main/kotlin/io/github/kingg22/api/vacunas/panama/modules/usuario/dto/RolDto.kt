package io.github.kingg22.api.vacunas.panama.modules.usuario.dto

import com.fasterxml.jackson.annotation.JsonProperty
import io.github.kingg22.api.vacunas.panama.modules.usuario.entity.Rol
import io.mcarle.konvert.api.KonvertFrom
import io.mcarle.konvert.api.KonvertTo
import io.mcarle.konvert.api.Mapping
import io.quarkus.runtime.annotations.RegisterForReflection
import jakarta.validation.Valid
import jakarta.validation.constraints.PastOrPresent
import jakarta.validation.constraints.Pattern
import jakarta.validation.constraints.Size
import java.io.Serializable
import java.time.LocalDateTime
import java.time.ZoneOffset.UTC

/**
 * DTO for [io.github.kingg22.api.vacunas.panama.modules.usuario.entity.Rol]
 *
 * _Warning_: nombre is required.
 * Default value ([RolDto.Companion.DEFAULT_ROL]) for [RolDto.nombre] if it is null.
 */
@RegisterForReflection
@KonvertTo(Rol::class, [Mapping("nombre", expression = "nombre ?: RolDto.DEFAULT_ROL")])
@KonvertFrom(Rol::class)
@JvmRecord
data class RolDto(
    val id: Short? = null,

    @all:Size(max = 100)
    @all:Pattern(regexp = "\\s*|\\S.*", message = "El nombre del rol es requerido")
    val nombre: String? = null,

    @all:Size(max = 100)
    val descripcion: String? = null,

    val permisos: Set<@Valid PermisoDto> = emptySet(),

    @all:JsonProperty(value = "created_at")
    @all:PastOrPresent(message = "La fecha de creación no puede ser futura")
    val createdAt: LocalDateTime = LocalDateTime.now(UTC),

    @all:JsonProperty(value = "updated_at")
    @all:PastOrPresent(message = "La fecha de actualización no puede ser futura")
    val updatedAt: LocalDateTime? = null,
) : Serializable {
    companion object {
        const val DEFAULT_ROL = "PACIENTE"
    }
}
