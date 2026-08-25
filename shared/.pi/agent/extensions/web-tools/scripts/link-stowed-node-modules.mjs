import { existsSync, lstatSync, realpathSync, symlinkSync, unlinkSync } from "node:fs";
import { dirname, join } from "node:path";

// GNU stow --no-folding installs each source file as a symlink. Node/Bun then
// resolve packages from the realpath (the dotfiles tree), not ~/.pi. If npm
// install ran in the stow target, point the source tree at that node_modules.
const cwd = process.cwd();
const realPackageDir = dirname(realpathSync(join(cwd, "package.json")));
if (realPackageDir === cwd) {
	process.exit(0);
}

const installedNodeModules = join(cwd, "node_modules");
const realNodeModules = join(realPackageDir, "node_modules");
if (!existsSync(installedNodeModules)) {
	process.exit(0);
}

if (existsSync(realNodeModules)) {
	if (!lstatSync(realNodeModules).isSymbolicLink()) {
		process.exit(0);
	}
	try {
		if (realpathSync(realNodeModules) === realpathSync(installedNodeModules)) {
			process.exit(0);
		}
	} catch {
		// dangling symlink
	}
	unlinkSync(realNodeModules);
}

symlinkSync(installedNodeModules, realNodeModules);
