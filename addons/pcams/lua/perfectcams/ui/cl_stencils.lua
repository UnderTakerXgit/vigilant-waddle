--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

function PerfectCams.UI.RoundedImage(rounded, x, y, w, h)
    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)

    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)
        draw.NoTexture()
        surface.SetDrawColor(255, 255, 255)

        -- Top left
        PerfectCams.UI.DrawCircle(x + rounded, y + rounded, rounded, 15)
        -- Top Right
        PerfectCams.UI.DrawCircle(x + w - rounded , y + rounded, rounded, 15)
        -- Bottom left
        PerfectCams.UI.DrawCircle(x + rounded, y + h - rounded, rounded, 15)
        -- Bottom right
        PerfectCams.UI.DrawCircle(x + w - rounded, y + h - rounded, rounded, 15)

        -- Fill the space
        draw.RoundedBox(0, x, y + rounded, w, h - (rounded * 2), color_white)
        draw.RoundedBox(0, x + rounded, y, w - (rounded * 2), h, color_white)

	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(1)
end


function PerfectCams.UI.RoundedImageEnd(x, y, w, h)
    render.SetStencilEnable(false)
    render.ClearStencil()
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
