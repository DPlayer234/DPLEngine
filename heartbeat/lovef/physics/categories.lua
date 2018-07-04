--[[
A wrapper for Löve-physics
Simplifies collision categories and masks.
]]
local lphysics = require "love.physics"
local bit = require "bit"

local assert, type = assert, type

local physics = {}

local MIN_GROUP = -(2 ^ 15) --#const
local MAX_GROUP = 2 ^ 15 - 1 --#const

local DEF_BITS = 1 --#const
local ALL_COLLIDE = 0xFFFF --#const

-- Store the collision groups
local categories = {}
local categoryCount = 0

local weakKeyTable = { __mode = "k" }

-- Stores category names
physics.categories = {}

-- Asserts whether the group index is valid.
function physics._assertGroupIndex(groupIndex)
	return assert(
		type(group) == "number" and group >= MIN_GROUP and group <= MAX_GROUP and group % 1 == 0,
		"'groupIndex' has to be an integer in the range -32768 to 32767.")
end

-- Asserts the given category and returns it.
function physics._assertCategory(categoryName)
	return assert(categories[categoryName], "There is no category of that name!")
end

-- Removes the fixture from a category
function physics._removeFixtureCategory(fixture, categoryName)
	local category = physics._assertCategory(categoryName)

	if not category.fixtures[fixture] then return end
	category.fixtures[fixture] = nil

	if not fixture:isDestroyed() then
		fixture:setFilterData(DEF_BITS, ALL_COLLIDE, 0)
	end
end

-- Sets the category of a fixture
function physics._setFixtureCategory(fixture, categoryName)
	local category = physics._assertCategory(categoryName)
	category.fixtures[fixture] = true

	if not fixture:isDestroyed() then
		fixture:setFilterData(category.bits, category.mask, 0)
	end
end

-- Adds a category. There can be at most 16, and there always is 'default' (1).
-- Returns the bits of that group alone.
function physics.addCategory(categoryName)
	assert(categoryCount < 16, "There are already 16 collision categories set.")
	assert(categories[categoryName] == nil, "There is already a collision category by that name.")

	local bits = bit.lshift(1, categoryCount)
	categoryCount = categoryCount + 1

	categories[categoryName] = {
		bits = bits,
		mask = ALL_COLLIDE,
		fixtures = setmetatable({}, weakKeyTable)
	}

	physics.categories[categoryCount] = categoryName

	return bits
end

-- Sets the collision categories to ignore certain categories when colliding.
function physics.setCollisionMasks(categoryName, overrides)
	assert(
		type(overrides) == "table",
		"You should supply a table, with the keys being category names and the value indicating whether to collide with that category")

	local category = physics._assertCategory(categoryName)

	local removeMask = 0
	local addMask = 0

	for iCatName, status in pairs(overrides) do
		local iCategory = physics._assertCategory(iCatName)

		if status then
			addMask = bit.bor(addMask, iCategory.bits)
		else
			removeMask = bit.bor(removeMask, iCategory.bits)
		end
	end

	-- Set bits in add mask to true
	category.mask = bit.bor(category.mask, addMask)

	-- Sets bits in ignore mask to false
	category.mask = bit.bnot(bit.bor(bit.bnot(category.mask), removeMask))

	-- Update fixture collisions
	for fixture, b in pairs(category.fixtures) do
		physics._setFixtureCategory(fixture, categoryName)
	end
end

-- Adds physic categories and their respective masks.
-- categoryData should be a table formatted as such:
--    categoryName = { ignoresCategory = false, collidesCategory = true }
-- Basically, the sub-tables would be arguments to physics.setCollisionMasks
function physics.addPhysicCategories(categoryData)
	for categoryName, overrides in pairs(categoryData) do
		physics.addCategory(categoryName)
	end

	for categoryName, overrides in pairs(categoryData) do
		physics.setCollisionMasks(categoryName, overrides)
	end
end

-- Returns the amount of free categories for collisions
function physics.getFreeCategoryCount()
	return 16 - categoryCount
end

-- Add the default category
physics.addCategory("default")

return physics
