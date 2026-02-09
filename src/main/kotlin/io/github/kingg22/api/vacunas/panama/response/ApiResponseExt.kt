package io.github.kingg22.api.vacunas.panama.response

/**
 * Check if this has errors.
 *
 * If the number of errors is equal to or greater than the value specified in the minErrors parameter (the default is 1),
 * it returns the object itself. Otherwise, it returns null.
 *
 * Example:
 * ```kotlin
 * fun controller(): ApiResponse {
 *     response.returnIfErrors()?.let { return it }
 *     // Do something without errors
 *     response.addData("foo", "bar")
 * }
 * ```
 *
 * @param minErrors Number of errors to evaluate
 * @return [ApiContentResponse] if the condition is true otherwise null
 */
fun ApiContentResponse.returnIfErrors(minErrors: Int = 1) = if (errors.size >= minErrors) this else null

/**
 * Convert an [ApiResponse] to [ApiResponseBuilder].
 * @return [ApiResponseBuilder] with all content of actual [ApiResponse]
 */
fun ApiResponse.asBuilder() = ApiResponseBuilder(this)

/**
 * Allows you to construct or modify an [ApiResponse] object using DSL style.
 * @return [ApiResponse] with all.
 */
fun ApiResponse.builder(block: ApiResponseBuilder.() -> Unit) =
    ApiResponseBuilder(this).apply(block).build()
