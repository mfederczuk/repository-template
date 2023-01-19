/*
 * Copyright (c) {{current_year}} {{COPYRIGHT_HOLDER}}
 * SPDX-License-Identifier: MPL-2.0 AND Apache-2.0
 */

import assert from "assert";
import { describe } from "mocha";
import { helloWorld } from "../src";

describe("helloWorld()", function() {
	it("should return \"Hello, World!\"", function() {
		assert.strictEqual(helloWorld(), "Hello, World!");
	});
});
