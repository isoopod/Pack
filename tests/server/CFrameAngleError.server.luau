-- Measures the average angle error after reconstructing a cframe as well as benchmarking CFrame compression
--if true then return end -- Disable

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testpacket = require(ReplicatedStorage.Packets.testpacket)

local r = Random.new()
local EPSILON = 1e-6

-- Function to convert a CFrame to a normalized quaternion
local function cfToNormalisedQuaternion(cf: CFrame): (number, number, number, number)
	local axis, angle = cf:Orthonormalize():ToAxisAngle()

	local d = axis.X * axis.X + axis.Y * axis.Y + axis.Z * axis.Z
	if math.abs(d) > EPSILON then axis = axis * (1 / math.sqrt(math.abs(d))) end

	local h = angle / 2
	local s = math.sin(h)
	axis = axis * s

	local x, y, z, w = axis.X, axis.Y, axis.Z, math.cos(h)
	d = x * x + y * y + z * z + w * w

	if math.abs(d) > EPSILON then
		d = math.sqrt(d)
		return x / d, y / d, z / d, w / d
	end

	return 0, 0, 0, 1 -- identity quaternion
end

-- Function to measure the angle in degrees between two CFrames
-- Doesnt work perfectly, treat results before March with a grain of salt. Simply checking angle between lookvectors now
local function _angleBetweenCFrames(cframe1: CFrame, cframe2: CFrame): number
	-- Convert CFrames to normalized quaternions
	local x1, y1, z1, w1 = cfToNormalisedQuaternion(cframe1)
	local x2, y2, z2, w2 = cfToNormalisedQuaternion(cframe2)

	-- Calculate the dot product of the two quaternions
	local dot = math.clamp(w1 * w2 + x1 * x2 + y1 * y2 + z1 * z2, -1, 1)

	-- Calculate the angle in radians and convert to degrees
	local angleRad = 2 * math.acos(math.abs(dot))
	local angleDeg = math.deg(angleRad)

	return angleDeg
end

local function getAngle(cf1: CFrame, cf2: CFrame): number
	return math.deg(math.acos(math.clamp(cf1.LookVector:Dot(cf2.LookVector), -1, 1)))
end

local total = 0
local upper, lower = -math.huge, math.huge
local count = 1000000

local start = os.clock()
for _ = 1, count do
	local before = CFrame.Angles(r:NextNumber(0, math.pi), r:NextInteger(0, math.pi), r:NextInteger(0, math.pi))
	local packet = testpacket:Write(before)
	local after = testpacket:Read(packet)
	local aerror = getAngle(before, after)
	--if aerror > 89 then continue end -- Remove outliers for this (axis aligned is borked rn)
	if aerror > 170 then warn(aerror, "before", before, "after", after, "len", buffer.len(packet)) end
	if aerror < lower then lower = aerror end
	if aerror > upper then upper = aerror end
	total += aerror
end

-- 22/01/25: The average angle error is < 0.0021, maximum angle error is ~0.03 and minimum is 0.
-- Note: Right now, the axis aligned is slightly broken and most of the time is completely wrong.
-- For this test, I filtered out the cases where the angle error was above 89 degrees because of this
-- as I just wanted to see how the random orientation compression was performing.

-- 21/02/25: Average angle error has been brought down to < 0.0006512, though max the max error here jumped to ~0.16
-- Axis aligned cases have been fixed

-- 5/03/25: Average angle of error is 0.00460889. max is ~0.04.
-- since the method for determining the angle between has changed, retesting v0.1.0 (comparable to 21/02/25 test) gives us an average of 0.0148617

print(`{count} CFrame operations took {(os.clock() - start) * 1000} ms to complete`)
print(`Average angle error between {count} random CFrames is {total / count} degrees`)
print(`Upper angle error bound was {upper} degrees. Lower angle error bound was {lower} degrees.`)
