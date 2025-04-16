<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Follow;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class UserController extends Controller
{
    public function profile(Request $request)
    {
        $user = $request->user();
        $user->profile_picture_url = $user->profile_picture ? Storage::url($user->profile_picture) : null;
        return response()->json($user);
    }

    public function userProfile(Request $request, User $user)
    {
        $user->profile_picture_url = $user->profile_picture ? Storage::url($user->profile_picture) : null;

        $user->is_followed = Follow::where('follower_id', $request->user()->id)
            ->where('followed_id', $user->id)
            ->exists() ? 1 : 0;

        $user->posts_count = Post::where('user_id', $user->id)->count();
        $user->followers_count = Follow::where('followed_id', $user->id)->count();
        $user->following_count = Follow::where('follower_id', $user->id)->count();
        
        return response()->json($user);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'username' => 'string|max:255|unique:users,username,' . $user->id,
            'email' => 'string|email|max:255|unique:users,email,' . $user->id,
            'phone_num' => 'nullable|string|max:15',
            'dob' => 'date|before:today',
            'gender' => 'in:Male,Female',
            'bio' => 'nullable|string|max:100',
            'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($request->hasFile('profile_picture')) {
            if ($user->profile_picture) {
                Storage::disk('public')->delete($user->profile_picture);
            }
            $user->profile_picture = $request->file('profile_picture')->store('profiles', 'public');
        }

        $user->update($request->only([
            'name', 'username', 'email', 'phone_num', 'dob', 'gender', 'bio'
        ]));

        $user->profile_picture_url = $user->profile_picture ? Storage::url($user->profile_picture) : null;

        return response()->json($user);
    }

    public function updatePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'password' => 'required|string|min:5|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = $request->user();
        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json(['message' => 'Password updated']);
    }
}
