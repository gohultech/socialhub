const MAX_AVATAR_SIZE = 5 * 1024 * 1024
const SUPPORTED_AVATAR_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"]

const showUploadError = (error, message) => {
  if (!error) return

  error.textContent = message
  error.hidden = false
}

const validateImage = (input, file, error) => {
  if (!SUPPORTED_AVATAR_TYPES.includes(file.type)) {
    input.value = ""
    showUploadError(error, "Please choose a JPG, PNG, WEBP, or GIF image.")
    return false
  }

  if (file.size > MAX_AVATAR_SIZE) {
    input.value = ""
    showUploadError(error, "Image must be smaller than 5 MB.")
    return false
  }

  if (error) error.hidden = true
  return true
}

const setupProfileAvatarPreview = () => {
  document.querySelectorAll("[data-profile-avatar-preview-target='input']").forEach((input) => {
    if (input.dataset.previewReady === "true") return

    input.dataset.previewReady = "true"
    input.addEventListener("change", () => {
      const error = input.closest(".edit-profile-photo-action")?.querySelector("[data-profile-avatar-preview-error]")
      const preview = input.closest(".edit-profile-photo-row")?.querySelector(".edit-profile-avatar")
      const file = input.files?.[0]

      if (!file) return

      if (!validateImage(input, file, error)) return

      if (preview) {
        const objectUrl = URL.createObjectURL(file)
        preview.src = objectUrl
        preview.onload = () => URL.revokeObjectURL(objectUrl)
        preview.classList.add("is-local-preview")
      }
    })
  })
}

const setupProfileCoverPreview = () => {
  document.querySelectorAll("[data-profile-cover-preview-target='input']").forEach((input) => {
    if (input.dataset.previewReady === "true") return

    input.dataset.previewReady = "true"
    input.addEventListener("change", () => {
      const section = input.closest(".edit-profile-cover-section")
      const error = section?.querySelector("[data-profile-cover-preview-error]")
      const preview = section?.querySelector("[data-profile-cover-preview]")
      const file = input.files?.[0]

      if (!file || !preview || !validateImage(input, file, error)) return

      const objectUrl = URL.createObjectURL(file)
      let image = preview.querySelector(".edit-profile-cover-image")

      if (!image) {
        image = document.createElement("img")
        image.className = "edit-profile-cover-image"
        image.alt = "Selected profile cover preview"
        preview.prepend(image)
      }

      image.src = objectUrl
      image.onload = () => URL.revokeObjectURL(objectUrl)
      preview.classList.add("has-image", "is-local-preview")
    })
  })
}

const setupProfileCoverUpload = () => {
  document.querySelectorAll("[data-profile-cover-upload-form]").forEach((form) => {
    if (form.dataset.uploadReady === "true") return

    const input = form.querySelector("[data-profile-cover-upload-target='input']")
    const trigger = form.querySelector("[data-profile-cover-upload-trigger]")
    const remove = form.querySelector("[data-profile-cover-upload-remove]")
    const status = form.querySelector("[data-profile-cover-upload-status]")
    const cover = form.closest(".profile-cover")
    const originalImage = cover?.querySelector(".profile-cover-image")
    let originalImageSrc = originalImage?.src
    let originallyHadImage = cover?.classList.contains("has-image")
    let uploadController

    if (!input || !trigger || !cover) return

    form.dataset.uploadReady = "true"

    const setStatus = (message, state = "") => {
      if (!status) return

      status.textContent = message
      status.hidden = !message
      status.dataset.state = state
    }

    const restoreCover = () => {
      uploadController?.abort()
      input.value = ""

      const currentImage = cover.querySelector(".profile-cover-image")
      if (originalImageSrc) {
        if (currentImage) {
          currentImage.src = originalImageSrc
        }
      } else {
        currentImage?.remove()
        cover.classList.remove("has-image")
      }

      cover.classList.remove("is-local-preview", "is-uploading")
      trigger.hidden = false
      if (remove) remove.hidden = true
      setStatus("")
    }

    const uploadCover = async (file) => {
      uploadController = new AbortController()
      cover.classList.add("is-uploading")
      if (remove) remove.hidden = false
      setStatus("Uploading cover photo…", "loading")

      try {
        const response = await fetch(form.action, {
          method: form.method.toUpperCase(),
          body: new FormData(form),
          credentials: "same-origin",
          headers: {
            Accept: "text/html",
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content || ""
          },
          signal: uploadController.signal
        })

        if (!response.ok) throw new Error("Cover upload failed")

        const responseHtml = await response.text()
        const persistedCover = new DOMParser().parseFromString(responseHtml, "text/html").querySelector(".profile-cover-image")
        const currentImage = cover.querySelector(".profile-cover-image")

        if (persistedCover?.src && currentImage) {
          originalImageSrc = persistedCover.src
          currentImage.src = persistedCover.src
        }

        originallyHadImage = true
        cover.classList.remove("is-uploading", "is-local-preview")
        trigger.hidden = false
        if (remove) remove.hidden = true
        setStatus("Cover photo updated.", "success")
      } catch (error) {
        if (error.name === "AbortError") return

        cover.classList.remove("is-uploading")
        restoreCover()
        setStatus("Cover photo could not be updated. Please try again.", "error")
      } finally {
        uploadController = null
      }
    }

    trigger.addEventListener("click", () => input.click())
    remove?.addEventListener("click", restoreCover)
    input.addEventListener("change", () => {
      const file = input.files?.[0]
      if (!file) return

      if (!validateImage(input, file, status)) {
        setStatus(status?.textContent || "Please choose a valid image.", "error")
        return
      }

      const objectUrl = URL.createObjectURL(file)
      let image = cover.querySelector(".profile-cover-image")
      if (!image) {
        image = document.createElement("img")
        image.className = "profile-cover-image"
        image.alt = "Selected profile cover preview"
        cover.prepend(image)
      }

      image.src = objectUrl
      image.onload = () => URL.revokeObjectURL(objectUrl)
      cover.classList.add("has-image", "is-local-preview")
      trigger.hidden = true
      uploadCover(file)
    })

    if (!originallyHadImage) cover.classList.remove("has-image")
  })
}

const setupProfileImagePreviews = () => {
  setupProfileAvatarPreview()
  setupProfileCoverPreview()
  setupProfileCoverUpload()
}

document.addEventListener("turbo:load", setupProfileImagePreviews)
document.addEventListener("DOMContentLoaded", setupProfileImagePreviews)
setupProfileImagePreviews()
