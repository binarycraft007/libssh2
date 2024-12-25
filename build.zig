const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ssh2_dep = b.dependency("libssh2", .{});

    const openssl_dep = b.dependency("openssl", .{
        .target = target,
        .optimize = optimize,
    });

    const config_h = b.addConfigHeader(.{
        .style = .{ .cmake = ssh2_dep.path("src/libssh2_config_cmake.h.in") },
        .include_path = "libssh2_config.h",
    }, .{
        .HAVE_UNISTD_H = 1,
        .HAVE_INTTYPES_H = 1,
        .HAVE_SYS_SELECT_H = 1,
        .HAVE_SYS_UIO_H = 1,
        .HAVE_SYS_SOCKET_H = 1,
        .HAVE_SYS_IOCTL_H = 1,
        .HAVE_SYS_TIME_H = 1,
        .HAVE_SYS_UN_H = 1,
        .HAVE_SYS_PARAM_H = 1,
        .HAVE_ARPA_INET_H = 1,
        .HAVE_NETINET_IN_H = 1,
        .HAVE_GETTIMEOFDAY = 1,
        .HAVE_STRTOLL = 1,
        .HAVE_STRTOI64 = null,
        .HAVE_SNPRINTF = 1,
        .HAVE_EXPLICIT_BZERO = 1,
        .HAVE_EXPLICIT_MEMSET = null,
        .HAVE_MEMSET_S = null,
        .HAVE_POLL = 1,
        .HAVE_SELECT = 1,
        .HAVE_O_NONBLOCK = 1,
        .HAVE_FIONBIO = null,
        .HAVE_IOCTLSOCKET_CASE = null,
        .HAVE_SO_NONBLOCK = null,
        .LIBSSH2_API = "__attribute__ ((__visibility__ (\"default\")))",
    });

    const lib = b.addStaticLibrary(.{
        .name = "ssh2",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(openssl_dep.artifact("openssl"));
    lib.defineCMacro("HAVE_CONFIG_H", null);
    lib.defineCMacro("LIBSSH2_OPENSSL", null);
    lib.addConfigHeader(config_h);
    lib.addCSourceFiles(.{
        .root = ssh2_dep.path("src"),
        .files = &ssh_src,
        .flags = &.{},
    });
    lib.addIncludePath(ssh2_dep.path("src"));
    lib.addIncludePath(ssh2_dep.path("include"));
    lib.installHeadersDirectory(ssh2_dep.path("include"), "", .{});
    lib.installConfigHeader(config_h);
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

const ssh_src = [_][]const u8{
    "agent.c",
    "bcrypt_pbkdf.c",
    "chacha.c",
    "channel.c",
    "cipher-chachapoly.c",
    "comp.c",
    "crypt.c",
    "crypto.c",
    "global.c",
    "hostkey.c",
    "keepalive.c",
    "kex.c",
    "knownhost.c",
    "mac.c",
    "misc.c",
    "packet.c",
    "pem.c",
    "poly1305.c",
    "publickey.c",
    "scp.c",
    "session.c",
    "sftp.c",
    "transport.c",
    "userauth.c",
    "userauth_kbd_packet.c",
    "version.c",
};
